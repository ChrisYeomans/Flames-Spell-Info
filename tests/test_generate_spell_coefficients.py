import csv
import io
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from tools.generate_spell_coefficients import build_lua_module


def csv_rows(header, rows):
    stream = io.StringIO()
    writer = csv.DictWriter(stream, fieldnames=header, lineterminator="\n")
    writer.writeheader()
    writer.writerows(rows)
    stream.seek(0)
    return list(csv.DictReader(stream))


class GenerateSpellCoefficientsTests(unittest.TestCase):
    def setUp(self):
        self.effects = csv_rows(
            [
                "SpellID",
                "DifficultyID",
                "EffectIndex",
                "Effect",
                "EffectAura",
                "EffectAuraPeriod",
                "EffectBonusCoefficient",
            ],
            [
                {
                    "SpellID": "133",
                    "DifficultyID": "0",
                    "EffectIndex": "0",
                    "Effect": "2",
                    "EffectAura": "0",
                    "EffectAuraPeriod": "0",
                    "EffectBonusCoefficient": "0.42899999022",
                },
                {
                    "SpellID": "133",
                    "DifficultyID": "0",
                    "EffectIndex": "1",
                    "Effect": "6",
                    "EffectAura": "3",
                    "EffectAuraPeriod": "2000",
                    "EffectBonusCoefficient": "0",
                },
                {
                    "SpellID": "172",
                    "DifficultyID": "0",
                    "EffectIndex": "0",
                    "Effect": "6",
                    "EffectAura": "3",
                    "EffectAuraPeriod": "3000",
                    "EffectBonusCoefficient": "0.20000000298",
                },
                {
                    "SpellID": "123",
                    "DifficultyID": "0",
                    "EffectIndex": "0",
                    "Effect": "2",
                    "EffectAura": "0",
                    "EffectAuraPeriod": "0",
                    "EffectBonusCoefficient": "0",
                },
                {
                    "SpellID": "123",
                    "DifficultyID": "0",
                    "EffectIndex": "1",
                    "Effect": "35",
                    "EffectAura": "77",
                    "EffectAuraPeriod": "0",
                    "EffectBonusCoefficient": "1",
                },
            ],
        )
        self.names = csv_rows(
            ["ID", "Name_lang"],
            [
                {"ID": "133", "Name_lang": "Fireball"},
                {"ID": "172", "Name_lang": "Corruption"},
                {"ID": "123", "Name_lang": "Unused spell"},
            ],
        )
        self.misc = csv_rows(
            ["SpellID", "DifficultyID", "DurationIndex", "SchoolMask"],
            [
                {"SpellID": "133", "DifficultyID": "0", "DurationIndex": "0", "SchoolMask": "4"},
                {"SpellID": "172", "DifficultyID": "0", "DurationIndex": "18", "SchoolMask": "32"},
            ],
        )
        self.durations = csv_rows(
            ["ID", "Duration"],
            [{"ID": "18", "Duration": "18000"}],
        )

    def test_preserves_per_spell_rank_and_periodic_effect_data(self):
        generated = build_lua_module(
            self.effects, self.names, self.misc, self.durations, "test-build"
        )

        self.assertIn('build = "test-build"', generated)
        self.assertIn("SpellInfo.GeneratedSpellCoefficients = {", generated)
        self.assertIn('[133] = {', generated)
        self.assertIn('name = "Fireball"', generated)
        self.assertIn("school = 4", generated)
        self.assertIn("durationMs = 0", generated)
        self.assertIn("coefficient = 0.429", generated)
        self.assertIn('[172] = {', generated)
        self.assertIn('name = "Corruption"', generated)
        self.assertIn("durationMs = 18000", generated)
        self.assertIn("periodMs = 3000", generated)
        self.assertIn("coefficient = 0.2", generated)
        self.assertNotIn("[123] = {", generated)

    def test_escapes_spell_names_for_lua(self):
        names = csv_rows(["ID", "Name_lang"], [{"ID": "133", "Name_lang": 'The "Fire" spell'}])
        generated = build_lua_module(
            self.effects[:1], names, self.misc, self.durations, "test-build"
        )
        self.assertIn(r'name = "The \"Fire\" spell"', generated)

    def test_rejects_conflicting_school_masks_at_same_difficulty(self):
        conflicting_misc = self.misc + [
            {"SpellID": "133", "DifficultyID": "0", "DurationIndex": "0", "SchoolMask": "16"}
        ]
        with self.assertRaisesRegex(ValueError, "conflicting duration or school"):
            build_lua_module(
                self.effects, self.names, conflicting_misc, self.durations, "test-build"
            )


if __name__ == "__main__":
    unittest.main()
