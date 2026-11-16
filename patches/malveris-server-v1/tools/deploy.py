"""Explicit WSL deployment to the existing cormyr service, with verified rollback."""
from pathlib import Path, PurePosixPath
import argparse
import datetime
import json
import subprocess
import sys
import tempfile

from patch_module import allowed_existing, apply_patch, load_bundle, sha

MODULE = '/nwn/home/modules/cormyr_spelltest.mod'
LOOSE_ROOTS = ('/nwn/home/development', '/nwn/home/override')


def verify_bundle(bundle):
    bundle = Path(bundle).resolve()
    for line in (bundle / 'SHA256SUMS').read_text().splitlines():
        digest, relative = line.split('  ', 1)
        path = (bundle / relative).resolve()
        if not path.is_relative_to(bundle) or sha(path.read_bytes()) != digest:
            raise ValueError('Bundle integrity check failed: ' + relative)
    return load_bundle(bundle)


class Docker:
    def __init__(self, project):
        self.project = Path(project).resolve()
        self.cid = self.run(['docker', 'compose', 'ps', '-a', '-q', 'cormyr']).strip()
        if not self.cid or '\n' in self.cid:
            raise ValueError('Expected exactly one existing cormyr container')

    def run(self, command):
        result = subprocess.run(command, cwd=self.project, text=True, capture_output=True)
        if result.returncode:
            raise RuntimeError(result.stderr.strip() or result.stdout.strip())
        return result.stdout

    def running(self):
        return self.run(['docker', 'inspect', '--format', '{{.State.Running}}', self.cid]).strip() == 'true'

    def stop(self):
        self.run(['docker', 'compose', 'stop', 'cormyr'])

    def start(self):
        # Start the existing game container only; no dependency/database operations.
        self.run(['docker', 'compose', 'start', 'cormyr'])

    def read(self, path):
        with tempfile.TemporaryDirectory(prefix='malveris-read-') as td:
            target = Path(td) / 'resource'
            result = subprocess.run(['docker', 'cp', f'{self.cid}:{path}', str(target)],
                                    cwd=self.project, text=True, capture_output=True)
            if result.returncode:
                error = result.stderr.lower()
                if 'could not find the file' in error:
                    return None
                raise RuntimeError(result.stderr.strip() or 'docker cp failed')
            return target.read_bytes()

    def write(self, path, data):
        with tempfile.TemporaryDirectory(prefix='malveris-write-') as td:
            source = Path(td) / 'resource'
            source.write_bytes(data)
            source.chmod(0o644)
            self.run(['docker', 'cp', str(source), f'{self.cid}:{path}'])


def save_record(folder, record):
    temp = folder / 'transaction.json.tmp'
    temp.write_text(json.dumps(record, indent=2) + '\n')
    temp.replace(folder / 'transaction.json')


def write_verified(backend, path, data):
    backend.write(path, data)
    if backend.read(path) != data:
        raise RuntimeError('Readback mismatch: ' + path)


def install(bundle, project, backend=None):
    bundle, project = Path(bundle).resolve(), Path(project).resolve()
    manifest, payloads = verify_bundle(bundle)
    backend = backend or Docker(project)
    running = backend.running()
    timestamp = datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%S%fZ')
    backup = project / 'backups' / ('malveris-' + timestamp)
    backup.mkdir(parents=True, mode=0o700)
    print('Backup:', backup, flush=True)
    writes = []
    stopped = False
    try:
        backend.stop()
        stopped = True
        original = backend.read(MODULE)
        if original is None:
            raise ValueError('Server module not found: ' + MODULE)
        (backup / 'original.mod').write_bytes(original)
        patched, changed = apply_patch(original, bundle)
        (backup / 'patched.mod').write_bytes(patched)
        loose = []
        # Do not silently leave a higher-priority loose script shadowing the patch.
        for entry in manifest['resources']:
            filename = Path(entry['path']).name
            wanted = payloads[entry['resref'], entry['type']]
            for root in LOOSE_ROOTS:
                path = root + '/' + filename
                old = backend.read(path)
                if old is None:
                    continue
                if not allowed_existing(manifest, entry['resref'], entry['type'], old, wanted):
                    raise ValueError('Unknown higher-priority resource: ' + path)
                if old != wanted:
                    relative = 'loose/' + str(len(loose))
                    (backup / 'loose').mkdir(exist_ok=True)
                    (backup / relative).write_bytes(old)
                    loose.append({'path': path, 'backup': relative,
                                  'before_sha256': sha(old), 'after_sha256': sha(wanted),
                                  'resource': [entry['resref'], entry['type']]})
        record = {'version': 1, 'state': 'prepared', 'module': MODULE,
                  'before_sha256': sha(original), 'after_sha256': sha(patched),
                  'was_running': running, 'loose': loose}
        save_record(backup, record)
        # Register each write before doing it: failed copies may be partial.
        if patched != original:
            writes.append((MODULE, original))
            write_verified(backend, MODULE, patched)
        for item in loose:
            old = (backup / item['backup']).read_bytes()
            writes.append((item['path'], old))
            wanted = payloads[tuple(item['resource'])]
            write_verified(backend, item['path'], wanted)
        record['state'] = 'installed'
        save_record(backup, record)
        if running:
            backend.start()
        print(f'Installed: {len(changed)} module resources; {len(loose)} loose overrides updated.')
        print('Teleport command: !malveris (or .malveris).')
        if not running:
            print('cormyr was stopped and remains stopped. Start it with: sudo docker compose up -d cormyr')
        return backup
    except BaseException:
        try:
            for path, old in reversed(writes):
                write_verified(backend, path, old)
            if (backup / 'transaction.json').exists():
                record = json.loads((backup / 'transaction.json').read_text())
                record['state'] = 'rolled_back' if writes else 'not_installed'
                save_record(backup, record)
        except BaseException as rollback_error:
            raise RuntimeError(f'Rollback failed; cormyr left stopped. Backup: {backup}. {rollback_error}') from rollback_error
        if running and stopped:
            backend.start()
        raise


def rollback(backup, project, backend=None):
    backup = Path(backup).resolve()
    record = json.loads((backup / 'transaction.json').read_text())
    if record.get('version') != 1 or record.get('module') != MODULE:
        raise ValueError('Unexpected backup manifest')
    original = (backup / 'original.mod').read_bytes()
    if sha(original) != record['before_sha256']:
        raise ValueError('Backup module hash mismatch')
    originals = [(MODULE, original, record['after_sha256'])]
    for item in record['loose']:
        path = PurePosixPath(item['path'])
        if str(path.parent) not in LOOSE_ROOTS or '..' in path.parts:
            raise ValueError('Invalid rollback resource path')
        source = (backup / item['backup']).resolve()
        if not source.is_relative_to(backup):
            raise ValueError('Backup resource path outside backup')
        data = source.read_bytes()
        if sha(data) != item['before_sha256']:
            raise ValueError('Backup resource hash mismatch')
        originals.append((str(path), data, item['after_sha256']))
    backend = backend or Docker(project)
    was_running = backend.running()
    backend.stop()
    written = []
    installed = {}
    try:
        # Reject rollback over someone else's later changes before any writes.
        for path, old, expected in originals:
            now = backend.read(path)
            if now is None or sha(now) not in (sha(old), expected):
                raise ValueError('Resource changed after installation: ' + path)
            installed[path] = now
        for path, old, _ in originals:
            written.append(path)
            write_verified(backend, path, old)
        record['state'] = 'rolled_back'
        save_record(backup, record)
    except BaseException:
        try:
            for path in reversed(written):
                write_verified(backend, path, installed[path])
        except BaseException as error:
            raise RuntimeError('Rollback copy failed; cormyr left stopped. Backup: ' + str(backup)) from error
        if was_running:
            backend.start()
        raise
    if was_running:
        backend.start()
    print('Restored:', backup)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--project', required=True, type=Path)
    parser.add_argument('--rollback', type=Path)
    args = parser.parse_args()
    try:
        if args.rollback:
            rollback(args.rollback, args.project)
        else:
            install(Path(__file__).resolve().parents[1], args.project)
    except Exception as error:
        print('ERROR:', error, file=sys.stderr)
        sys.exit(1)
