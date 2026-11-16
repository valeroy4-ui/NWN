"""Build an additive patch from the two supplied modules. No game/server actions."""
from pathlib import Path
import argparse
import copy
import hashlib
import json
import shutil
import struct
import subprocess

from nwn_resources import erf_index, erf_rebuild, gff_read, gff_write, resref, value
from patch_module import apply_patch, sha

SCRIPT_NAMES = ['p_malv_heart', 'malv_spawn', 'malv_round', 'malv_death', 'malv_jump', '_mod_chat']
EVENTS = {'ScriptHeartbeat': 'p_malv_heart', 'ScriptSpawn': 'malv_spawn',
          'ScriptEndRound': 'malv_round', 'ScriptDeath': 'malv_death'}


def adapt_creature(blob):
    kind, node = gff_read(blob)
    before = copy.deepcopy(node)
    for field, name in EVENTS.items():
        if field not in node[1]:
            raise ValueError('Missing creature event: ' + field)
        node[1][field] = resref(name)
    for name, field in before[1].items():
        if name not in EVENTS and node[1][name] != field:
            raise ValueError('Unrelated creature field changed: ' + name)
    return gff_write(kind, node)


def build(source, server_module, boss_module, compiler, output):
    source, output = Path(source).resolve(), Path(output).resolve()
    if output.exists():
        raise ValueError('Output folder already exists: ' + str(output))
    server_blob, boss_blob = Path(server_module).read_bytes(), Path(boss_module).read_bytes()
    server, boss = erf_index(server_blob), erf_index(boss_blob)
    output.mkdir(parents=True)
    for sub in ['source', 'vendor', 'tools', 'tests']:
        shutil.copytree(source / sub, output / sub, ignore=shutil.ignore_patterns('__pycache__', '*.pyc'))
    for name in ['README_RU.md', 'rebuild.sh']:
        shutil.copy2(source / name, output / name)
    (output / 'compiled').mkdir()
    command = [str(Path(compiler).resolve()), '-i', f'{output / "source"};{output / "vendor"}',
               '-b', str(output / 'compiled')] + [s + '.nss' for s in SCRIPT_NAMES]
    done = subprocess.run(command, cwd=output / 'source', text=True, capture_output=True)
    (output / 'COMPILE_LOG.txt').write_text(done.stdout + done.stderr)
    if done.returncode:
        raise ValueError('Compilation failed: ' + done.stdout + done.stderr)
    payloads, paths = {}, {}
    for p in sorted((output / 'source').glob('*.nss')):
        payloads[p.stem, 2009] = p.read_bytes()
        paths[p.stem, 2009] = 'source/' + p.name
    for name in SCRIPT_NAMES:
        p = output / 'compiled' / (name + '.ncs')
        if not p.read_bytes().startswith(b'NCS V1.0'):
            raise ValueError('Invalid compiled script: ' + name)
        payloads[name, 2010] = p.read_bytes()
        paths[name, 2010] = 'compiled/' + p.name
    # The chat change must be exactly one additional early-return command block.
    block = '''    if (msg == "!malveris" || msg == ".malveris")
    {
        object pc = GetPCChatSpeaker();
        SetPCChatMessage("");
        if (GetIsPC(pc)) ExecuteScript("malv_jump",pc);
        return;
    }
'''
    old_chat = server['_mod_chat', 2009].decode('utf-8-sig').replace('\r\n', '\n')
    new_chat = payloads['_mod_chat', 2009].decode().replace('\r\n', '\n')
    if new_chat.replace(block, '', 1).rstrip() != old_chat.rstrip():
        raise ValueError('The current chat source differs from the reviewed baseline')
    (output / 'resources').mkdir()
    payloads['malveris', 2027] = adapt_creature(boss['malveris', 2027])
    payloads['prism_sweep_end', 2027] = boss['prism_sweep_end', 2027]
    for typ in [2012, 2023, 2046]:
        blob = boss['area', typ]
        if typ == 2023:
            kind, node = gff_read(blob)
            matched = 0
            for entry in node[1]['Creature List'][1]:
                if value(entry[1], 'TemplateResRef') == 'malveris':
                    adapted = gff_read(adapt_creature(gff_write(kind, entry)))[1]
                    entry[1].clear()
                    entry[1].update(adapted[1])
                    matched += 1
            if matched != 1:
                raise ValueError('Expected exactly one placed Malveris')
            blob = gff_write(kind, node)
        payloads['ct_malveris', typ] = blob
    extensions = {2012: '.are', 2023: '.git', 2046: '.gic', 2027: '.utc'}
    for (name, typ), blob in list(payloads.items()):
        if typ in extensions:
            path = 'resources/' + name + extensions[typ]
            (output / path).write_bytes(blob)
            paths[name, typ] = path
    allowed_previous = {}
    for key in payloads:
        # Only reviewed predecessors are accepted, never an arbitrary overwrite.
        previous = []
        if key == ('_mod_chat', 2009) or key == ('_mod_chat', 2010):
            previous.append(sha(server[key]))
        elif key[0] in ('malveris', 'p_malv_heart') and key in boss:
            previous.append(sha(boss[key]))
        allowed_previous[f'{key[0]}:{key[1]}'] = previous
    manifest = {
        'version': 'malveris-server-v1', 'module_file': 'cormyr_spelltest.mod',
        'service': 'cormyr', 'area': 'ct_malveris',
        'baseline_server_sha256': sha(server_blob), 'boss_source_sha256': sha(boss_blob),
        'native_gameplay_tested': False,
        'resources': [{'resref': name, 'type': typ, 'path': paths[name, typ], 'sha256': sha(blob)}
                      for (name, typ), blob in sorted(payloads.items())],
        'allowed_previous': allowed_previous,
    }
    (output / 'manifest.json').write_text(json.dumps(manifest, indent=2, ensure_ascii=False) + '\n')
    header = bytearray(160)
    header[:8] = b'ERF V1.0'
    struct.pack_into('<III', header, 20, 160, 160, 160)
    struct.pack_into('<I', header, 40, 0xffffffff)
    (output / 'module').mkdir()
    (output / 'module/malveris_v1.erf').write_bytes(erf_rebuild(bytes(header), payloads))
    patched, changed = apply_patch(server_blob, output)
    # Idempotence and preservation are checked against the real supplied module.
    second, repeat = apply_patch(patched, output)
    if second != patched or repeat:
        raise ValueError('Patch is not idempotent')
    verification = {
        'compiled_scripts': len(SCRIPT_NAMES), 'changed_resources': [list(k) for k in changed],
        'unchanged_original_payloads': sum(k not in changed for k in server),
        'idempotent': True, 'native_gameplay_tested': False,
        'patched_module_sha256': sha(patched),
    }
    (output / 'VERIFICATION.json').write_text(json.dumps(verification, indent=2) + '\n')
    lines = []
    for p in sorted(output.rglob('*')):
        if p.is_file():
            lines.append(sha(p.read_bytes()) + '  ' + str(p.relative_to(output)))
    (output / 'SHA256SUMS').write_text('\n'.join(lines) + '\n')
    return verification


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--server-module', required=True, type=Path)
    parser.add_argument('--boss-module', required=True, type=Path)
    parser.add_argument('--compiler', required=True, type=Path)
    parser.add_argument('--output', required=True, type=Path)
    args = parser.parse_args()
    result = build(Path(__file__).resolve().parents[1], args.server_module, args.boss_module,
                   args.compiler, args.output)
    print(json.dumps(result, indent=2))
