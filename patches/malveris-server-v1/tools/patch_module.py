"""Apply only the declared Malveris resources and one area-list entry."""
from pathlib import Path
import copy
import hashlib
import json

from nwn_resources import erf_index, erf_update, gff_read, gff_write, resref, value


def sha(data):
    return hashlib.sha256(data).hexdigest()


def load_bundle(bundle):
    bundle = Path(bundle)
    manifest = json.loads((bundle / 'manifest.json').read_text())
    result = {}
    for entry in manifest['resources']:
        name, kind = entry['resref'], entry['type']
        if len(name) > 16 or name != name.lower():
            raise ValueError('Invalid resource name')
        path = (bundle / entry['path']).resolve()
        if not path.is_relative_to(bundle.resolve()):
            raise ValueError('Resource path outside bundle')
        data = path.read_bytes()
        if sha(data) != entry['sha256']:
            raise ValueError('Bundle hash mismatch: ' + entry['path'])
        result[name, kind] = data
    return manifest, result


def allowed_existing(manifest, name, kind, data, wanted):
    if data == wanted:
        return True
    key = f'{name}:{kind}'
    return sha(data) in manifest['allowed_previous'].get(key, [])


def apply_patch(original, bundle):
    manifest, payloads = load_bundle(bundle)
    existing = erf_index(original)
    updates = {}
    for (name, kind), payload in payloads.items():
        previous = existing.get((name, kind))
        if previous is not None and not allowed_existing(manifest, name, kind, previous, payload):
            raise ValueError(f'Unknown existing resource: {name} ({kind}); nothing overwritten')
        if previous != payload:
            updates[name, kind] = payload
    if ('module', 2014) not in existing:
        raise ValueError('module.ifo is missing')
    kind, node = gff_read(existing['module', 2014])
    revised = copy.deepcopy(node)
    fields = revised[1]
    if 'Mod_Area_list' not in fields or fields['Mod_Area_list'][0] != 15:
        raise ValueError('Unexpected module area list')
    areas = fields['Mod_Area_list'][1]
    matches = [area for area in areas if value(area[1], 'Area_Name') == 'ct_malveris']
    if len(matches) > 1:
        raise ValueError('Duplicate ct_malveris area entries')
    if not matches:
        areas.append([6, {'Area_Name': resref('ct_malveris')}])
        updates['module', 2014] = gff_write(kind, revised)
    patched = erf_update(original, updates) if updates else original
    checked = erf_index(patched)
    for key, data in existing.items():
        if key not in updates and checked.get(key) != data:
            raise ValueError('Unrelated resource changed: ' + str(key))
    for key, data in updates.items():
        if checked.get(key) != data:
            raise ValueError('Written resource verification failed: ' + str(key))
    # Every module property other than the area list must remain identical.
    _, after = gff_read(checked['module', 2014])
    before_fields = copy.deepcopy(node[1])
    after_fields = copy.deepcopy(after[1])
    before_fields.pop('Mod_Area_list')
    after_fields.pop('Mod_Area_list')
    if before_fields != after_fields:
        raise ValueError('Unrelated module properties changed')
    return patched, sorted(updates)


if __name__ == '__main__':
    import argparse
    p = argparse.ArgumentParser()
    p.add_argument('original', type=Path)
    p.add_argument('output', type=Path)
    p.add_argument('--bundle', type=Path, default=Path(__file__).resolve().parents[1])
    args = p.parse_args()
    if args.original.resolve() == args.output.resolve():
        p.error('Use a separate output file; never overwrite the input module')
    data, changed = apply_patch(args.original.read_bytes(), args.bundle)
    args.output.write_bytes(data)
    assert args.output.read_bytes() == data
    print('Changed resources:', len(changed))
    print('Output SHA256:', sha(data))
