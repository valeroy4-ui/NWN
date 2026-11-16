"""Resource-level and deployment-transaction tests, using the supplied real MODs.

These tests do not simulate or claim NWN combat/AI execution.
"""
from pathlib import Path
import copy
import json
import os
import shutil
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'tools'))
from nwn_resources import erf_index, erf_update, gff_read, value
from patch_module import apply_patch, load_bundle, sha
from deploy import MODULE, install, rollback

BUNDLE = Path(os.environ.get('MALV_BUNDLE', ROOT))
SERVER_PATH = os.environ.get('MALV_SERVER')
BOSS_PATH = os.environ.get('MALV_BOSS')


class FakeDocker:
    def __init__(self, original, running=True):
        self.files = {MODULE: original}
        self.active = running
        self.calls = []
        self.fail_once = None

    def running(self):
        return self.active

    def stop(self):
        self.calls.append('stop:cormyr')
        self.active = False

    def start(self):
        self.calls.append('start:cormyr')
        self.active = True

    def read(self, path):
        return self.files.get(path)

    def write(self, path, data):
        self.calls.append('write:' + path)
        if path == self.fail_once:
            self.fail_once = None
            self.files[path] = data[:64]  # A failed copy may have truncated a file.
            raise OSError('Injected copy failure')
        self.files[path] = data


@unittest.skipUnless(SERVER_PATH and BOSS_PATH, 'Set MALV_SERVER and MALV_BOSS to the supplied MODs')
class PatchTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.original = Path(SERVER_PATH).read_bytes()
        cls.boss_blob = Path(BOSS_PATH).read_bytes()
        cls.before = erf_index(cls.original)
        cls.boss = erf_index(cls.boss_blob)
        cls.patched, cls.changed = apply_patch(cls.original, BUNDLE)
        cls.after = erf_index(cls.patched)
        cls.manifest, cls.payloads = load_bundle(BUNDLE)

    def test_all_unrelated_payloads_preserved_byte_for_byte(self):
        allowed = set(self.payloads) | {('module', 2014)}
        checked = 0
        for key, blob in self.before.items():
            if key not in allowed:
                self.assertEqual(self.after[key], blob, key)
                checked += 1
        self.assertGreater(checked, 5000)

    def test_native_ai_and_map_are_exactly_the_current_server_versions(self):
        for key, blob in self.before.items():
            if key[0].startswith(('ai_', 'nw_c2_', 'j_inc_', 'cm_', 'dq_', 'crf_', 'crift')):
                self.assertEqual(blob, self.after[key], key)

    def test_area_registered_once_without_changing_other_module_settings(self):
        _, before = gff_read(self.before['module', 2014])
        _, after = gff_read(self.after['module', 2014])
        original_areas = before[1].pop('Mod_Area_list')[1]
        new_areas = after[1].pop('Mod_Area_list')[1]
        self.assertEqual(before, after)
        self.assertEqual(new_areas[:-1], original_areas)
        self.assertEqual(value(new_areas[-1][1], 'Area_Name'), 'ct_malveris')
        self.assertEqual(len(new_areas), len(original_areas) + 1)

    def test_blueprint_and_placed_boss_have_correct_native_wrappers(self):
        _, original = gff_read(self.boss['malveris', 2027])
        _, blueprint = gff_read(self.after['malveris', 2027])
        _, git = gff_read(self.after['ct_malveris', 2023])
        placed = [node for node in git[1]['Creature List'][1]
                  if value(node[1], 'TemplateResRef') == 'malveris']
        self.assertEqual(len(placed), 1)
        events = {'ScriptHeartbeat': 'p_malv_heart', 'ScriptSpawn': 'malv_spawn',
                  'ScriptEndRound': 'malv_round', 'ScriptDeath': 'malv_death'}
        for key, expected in events.items():
            self.assertEqual(value(blueprint[1], key), expected)
            self.assertEqual(value(placed[0][1], key), expected)
        for key in events:
            original[1].pop(key)
            blueprint[1].pop(key)
        self.assertEqual(original, blueprint)  # Stats, gear and all other handlers unchanged.

    def test_chat_preserves_original_commands_exactly(self):
        old = self.before['_mod_chat', 2009].decode().strip()
        new = self.after['_mod_chat', 2009].decode().strip()
        a = new.index('    if (msg == "!malveris"')
        b = new.index('    if (msg == "!dailytest"')
        self.assertEqual((new[:a] + new[b:]).strip(), old)
        self.assertIn(('malv_jump', 2010), self.after)

    def test_repeat_application_is_byte_identical(self):
        twice, changed = apply_patch(self.patched, BUNDLE)
        self.assertEqual(twice, self.patched)
        self.assertEqual(changed, [])

    def test_unknown_existing_chat_is_rejected(self):
        changed = erf_update(self.original, {('_mod_chat', 2010): b'unknown custom chat'})
        with self.assertRaisesRegex(ValueError, 'Unknown existing resource'):
            apply_patch(changed, BUNDLE)

    def test_unknown_existing_area_is_rejected(self):
        changed = erf_update(self.original, {('ct_malveris', 2012): b'someone else\'s area'})
        with self.assertRaisesRegex(ValueError, 'Unknown existing resource'):
            apply_patch(changed, BUNDLE)

    def test_install_and_explicit_rollback_restore_exact_module_and_loose_chat(self):
        backend = FakeDocker(self.original)
        path = '/nwn/home/development/_mod_chat.ncs'
        backend.files[path] = self.before['_mod_chat', 2010]
        with tempfile.TemporaryDirectory() as td:
            backup = install(BUNDLE, Path(td), backend)
            self.assertEqual(backend.files[MODULE], self.patched)
            self.assertEqual(backend.files[path], self.after['_mod_chat', 2010])
            self.assertTrue(backend.active)
            rollback(backup, Path(td), backend)
            self.assertEqual(backend.files[MODULE], self.original)
            self.assertEqual(backend.files[path], self.before['_mod_chat', 2010])
            self.assertTrue(backend.active)
        self.assertFalse(any('ct-db' in call for call in backend.calls))

    def test_partial_loose_copy_failure_restores_module_and_loose_file(self):
        backend = FakeDocker(self.original)
        path = '/nwn/home/override/_mod_chat.ncs'
        backend.files[path] = self.before['_mod_chat', 2010]
        backend.fail_once = path
        with tempfile.TemporaryDirectory() as td:
            with self.assertRaises(OSError):
                install(BUNDLE, Path(td), backend)
        self.assertEqual(backend.files[MODULE], self.original)
        self.assertEqual(backend.files[path], self.before['_mod_chat', 2010])
        self.assertTrue(backend.active)

    def test_partial_module_copy_failure_restores_module(self):
        backend = FakeDocker(self.original)
        backend.fail_once = MODULE
        with tempfile.TemporaryDirectory() as td:
            with self.assertRaises(OSError):
                install(BUNDLE, Path(td), backend)
        self.assertEqual(backend.files[MODULE], self.original)
        self.assertTrue(backend.active)

    def test_unknown_loose_override_aborts_before_writing_and_restarts_game(self):
        backend = FakeDocker(self.original)
        path = '/nwn/home/override/p_malv_heart.ncs'
        backend.files[path] = b'unknown later boss code'
        with tempfile.TemporaryDirectory() as td:
            with self.assertRaisesRegex(ValueError, 'Unknown higher-priority resource'):
                install(BUNDLE, Path(td), backend)
        self.assertFalse(any(call.startswith('write:') for call in backend.calls))
        self.assertEqual(backend.files[MODULE], self.original)
        self.assertTrue(backend.active)

    def test_stopped_service_is_not_started(self):
        backend = FakeDocker(self.original, running=False)
        with tempfile.TemporaryDirectory() as td:
            install(BUNDLE, Path(td), backend)
        self.assertFalse(backend.active)
        self.assertNotIn('start:cormyr', backend.calls)

    def test_rollback_rejects_later_changes_without_overwriting_them(self):
        backend = FakeDocker(self.original)
        with tempfile.TemporaryDirectory() as td:
            backup = install(BUNDLE, Path(td), backend)
            foreign = b'new module installed later'
            backend.files[MODULE] = foreign
            with self.assertRaisesRegex(ValueError, 'changed after installation'):
                rollback(backup, Path(td), backend)
        self.assertEqual(backend.files[MODULE], foreign)
        self.assertTrue(backend.active)

    def test_corrupt_bundle_is_rejected_before_stopping_service(self):
        backend = FakeDocker(self.original)
        with tempfile.TemporaryDirectory() as td:
            td = Path(td)
            copied = td / 'bundle'
            shutil.copytree(BUNDLE, copied)
            (copied / 'source/malv_inc.nss').write_text('corrupted')
            with self.assertRaisesRegex(ValueError, 'integrity check failed'):
                install(copied, td / 'project', backend)
        self.assertEqual(backend.calls, [])
        self.assertTrue(backend.active)


if __name__ == '__main__':
    unittest.main()
