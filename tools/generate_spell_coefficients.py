#!/usr/bin/env python3
"""Generate a standalone Lua module of per-effect SpellPower coefficients from Wago DB2.

By default, fetches SpellEffect, SpellName, SpellMisc, and SpellDuration for build 1.60.1.70450
and writes SpellPowerCoefficients.generated.lua in the add-on root. For offline
use, pass all four corresponding CSV paths.
"""

from __future__ import annotations

import argparse
import csv
import io
import math
import sys
import urllib.error
import urllib.parse
import urllib.request
from collections import defaultdict
from pathlib import Path
from typing import Iterable, TextIO


DEFAULT_BUILD = "1.60.1.70450"
TABLE_URL = "https://wago.tools/db2/{table}/csv?{query}"
USER_AGENT = "SpellInfo spell coefficient generator"

EFFECT_COLUMNS = {
    "SpellID",
    "DifficultyID",
    "EffectIndex",
    "Effect",
    "EffectAura",
    "EffectAuraPeriod",
    "EffectBonusCoefficient",
}
NAME_COLUMNS = {"ID", "Name_lang"}
MISC_COLUMNS = {"SpellID", "DifficultyID", "DurationIndex", "SchoolMask"}
DURATION_COLUMNS = {"ID", "Duration"}
SUPPORTED_EFFECTS = {2, 10}
SUPPORTED_AURAS = {3, 8, 69}


def parse_integer(value: str, column: str) -> int:
    try:
        return int(value)
    except (TypeError, ValueError) as error:
        raise ValueError(f"Invalid integer in DB2 column {column}: {value!r}") from error


def lua_string(value: str) -> str:
    escaped = []
    for character in value:
        codepoint = ord(character)
        if character == "\\":
            escaped.append("\\\\")
        elif character == '"':
            escaped.append('\\"')
        elif character == "\n":
            escaped.append("\\n")
        elif character == "\r":
            escaped.append("\\r")
        elif character == "\t":
            escaped.append("\\t")
        elif codepoint < 32 or codepoint == 127:
            escaped.append(f"\\{codepoint:03d}")
        else:
            escaped.append(character)
    return '"' + "".join(escaped) + '"'


def format_number(value: float) -> str:
    if not math.isfinite(value):
        raise ValueError(f"Non-finite coefficient: {value!r}")
    rounded = round(value, 6)
    if rounded == 0:
        return "0"
    return f"{rounded:.6f}".rstrip("0").rstrip(".")


def read_rows(stream: TextIO, required_columns: set[str], table: str) -> Iterable[dict[str, str]]:
    reader = csv.DictReader(stream)
    if reader.fieldnames is None:
        raise ValueError(f"{table} CSV is empty")
    missing_columns = required_columns.difference(reader.fieldnames)
    if missing_columns:
        missing = ", ".join(sorted(missing_columns))
        raise ValueError(f"{table} CSV is missing required columns: {missing}")
    return reader


def fetch_rows(table: str, build: str, required_columns: set[str]) -> Iterable[dict[str, str]]:
    query = urllib.parse.urlencode({"build": build})
    url = TABLE_URL.format(table=table, query=query)
    request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    try:
        response = urllib.request.urlopen(request, timeout=120)
    except (urllib.error.URLError, TimeoutError) as error:
        raise RuntimeError(f"Could not download {table} CSV from {url}: {error}") from error

    try:
        stream = io.TextIOWrapper(response, encoding="utf-8-sig", newline="")
        reader = read_rows(stream, required_columns, table)
        return list(reader)
    except (UnicodeError, csv.Error, ValueError) as error:
        raise RuntimeError(f"Could not parse {table} CSV from {url}: {error}") from error
    finally:
        response.close()


def read_local_rows(path: Path, required_columns: set[str], table: str) -> list[dict[str, str]]:
    try:
        with path.open("r", encoding="utf-8-sig", newline="") as stream:
            return list(read_rows(stream, required_columns, table))
    except (OSError, UnicodeError, csv.Error, ValueError) as error:
        raise RuntimeError(f"Could not read {table} CSV at {path}: {error}") from error


def build_lua_module(
    effect_rows: Iterable[dict[str, str]],
    name_rows: Iterable[dict[str, str]],
    misc_rows: Iterable[dict[str, str]],
    duration_rows: Iterable[dict[str, str]],
    build: str,
) -> str:
    names: dict[int, str] = {}
    for row in name_rows:
        spell_id = parse_integer(row["ID"], "SpellName.ID")
        name = row["Name_lang"]
        if name:
            names[spell_id] = name

    durations: dict[int, int] = {}
    for row in duration_rows:
        duration_id = parse_integer(row["ID"], "SpellDuration.ID")
        durations[duration_id] = parse_integer(row["Duration"], "SpellDuration.Duration")

    misc_by_spell: dict[int, tuple[int, int, int]] = {}
    for row in misc_rows:
        spell_id = parse_integer(row["SpellID"], "SpellMisc.SpellID")
        difficulty = parse_integer(row["DifficultyID"], "SpellMisc.DifficultyID")
        duration_index = parse_integer(row["DurationIndex"], "SpellMisc.DurationIndex")
        school = parse_integer(row["SchoolMask"], "SpellMisc.SchoolMask")
        previous = misc_by_spell.get(spell_id)
        if previous is None or (difficulty == 0 and previous[0] != 0) or difficulty < previous[0]:
            misc_by_spell[spell_id] = (difficulty, duration_index, school)
        elif difficulty == previous[0] and (duration_index, school) != previous[1:]:
            raise ValueError(
                f"SpellID {spell_id} has conflicting duration or school values for "
                f"DifficultyID {difficulty}"
            )

    effects_by_spell: dict[int, list[dict[str, int | float]]] = defaultdict(list)
    for row in effect_rows:
        effect = parse_integer(row["Effect"], "SpellEffect.Effect")
        aura = parse_integer(row["EffectAura"], "SpellEffect.EffectAura")
        if effect not in SUPPORTED_EFFECTS and aura not in SUPPORTED_AURAS:
            continue
        coefficient_text = row["EffectBonusCoefficient"].strip()
        if not coefficient_text:
            continue
        try:
            coefficient = float(coefficient_text)
        except ValueError as error:
            raise ValueError(
                "Invalid float in DB2 column EffectBonusCoefficient: "
                f"{coefficient_text!r}"
            ) from error
        if not math.isfinite(coefficient) or coefficient == 0:
            continue

        spell_id = parse_integer(row["SpellID"], "SpellEffect.SpellID")
        effects_by_spell[spell_id].append({
            "difficulty": parse_integer(row["DifficultyID"], "SpellEffect.DifficultyID"),
            "index": parse_integer(row["EffectIndex"], "SpellEffect.EffectIndex"),
            "effect": effect,
            "aura": aura,
            "periodMs": parse_integer(row["EffectAuraPeriod"], "SpellEffect.EffectAuraPeriod"),
            "coefficient": coefficient,
        })

    missing_names = sorted(set(effects_by_spell).difference(names))
    if missing_names:
        ids = ", ".join(str(spell_id) for spell_id in missing_names[:10])
        suffix = " ..." if len(missing_names) > 10 else ""
        raise ValueError(f"SpellName CSV has no English name for coefficient SpellID(s): {ids}{suffix}")

    lines = [
        "-- Generated by tools/generate_spell_coefficients.py from Wago.Tools DB2.",
        f"-- Build: {build}",
        "-- Coefficients are per-effect values, keyed by rank-specific SpellID.",
        "-- Periodic effects retain their per-tick coefficient and periodMs.",
        "SpellInfo = SpellInfo or {}",
        "SpellInfo.GeneratedSpellCoefficients = {",
        f"\tbuild = {lua_string(build)},",
        "\tspells = {",
    ]
    for spell_id in sorted(effects_by_spell):
        effects = sorted(
            effects_by_spell[spell_id],
            key=lambda effect: (effect["difficulty"], effect["index"]),
        )
        _, duration_index, school = misc_by_spell.get(spell_id, (0, 0, 0))
        duration_ms = durations.get(duration_index, 0)
        lines.extend([
            f"\t\t[{spell_id}] = {{",
            f"\t\t\tname = {lua_string(names[spell_id])},",
            f"\t\t\tschool = {school},",
            f"\t\t\tdurationMs = {duration_ms},",
            "\t\t\teffects = {",
        ])
        for effect in effects:
            lines.append(
                "\t\t\t\t{ "
                f"difficulty = {effect['difficulty']}, "
                f"index = {effect['index']}, "
                f"effect = {effect['effect']}, "
                f"aura = {effect['aura']}, "
                f"periodMs = {effect['periodMs']}, "
                f"coefficient = {format_number(effect['coefficient'])} "
                "},"
            )
        lines.extend(["\t\t\t},", "\t\t},"])
    lines.extend(["\t},", "}", ""])
    return "\n".join(lines)


def parse_arguments() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Generate a SpellID-keyed Lua module from Wago SpellEffect DB2 data."
    )
    parser.add_argument("--build", default=DEFAULT_BUILD, help=f"Wago build (default: {DEFAULT_BUILD})")
    parser.add_argument(
        "--output",
        type=Path,
        default=Path(__file__).resolve().parent.parent / "SpellPowerCoefficients.generated.lua",
        help="Output Lua path (default: SpellPowerCoefficients.generated.lua in the add-on root)",
    )
    parser.add_argument("--spell-effect-csv", type=Path, help="Use a local SpellEffect CSV instead of Wago")
    parser.add_argument("--spell-name-csv", type=Path, help="Use a local SpellName CSV instead of Wago")
    parser.add_argument("--spell-misc-csv", type=Path, help="Use a local SpellMisc CSV instead of Wago")
    parser.add_argument("--spell-duration-csv", type=Path, help="Use a local SpellDuration CSV instead of Wago")
    args = parser.parse_args()
    local_csvs = (
        args.spell_effect_csv,
        args.spell_name_csv,
        args.spell_misc_csv,
        args.spell_duration_csv,
    )
    if any(local_csvs) and not all(local_csvs):
        parser.error(
            "local CSV mode requires --spell-effect-csv, --spell-name-csv, "
            "--spell-misc-csv, and --spell-duration-csv"
        )
    return args


def main() -> int:
    args = parse_arguments()
    if args.spell_effect_csv:
        effect_rows = read_local_rows(args.spell_effect_csv, EFFECT_COLUMNS, "SpellEffect")
        name_rows = read_local_rows(args.spell_name_csv, NAME_COLUMNS, "SpellName")
        misc_rows = read_local_rows(args.spell_misc_csv, MISC_COLUMNS, "SpellMisc")
        duration_rows = read_local_rows(args.spell_duration_csv, DURATION_COLUMNS, "SpellDuration")
    else:
        effect_rows = fetch_rows("SpellEffect", args.build, EFFECT_COLUMNS)
        name_rows = fetch_rows("SpellName", args.build, NAME_COLUMNS)
        misc_rows = fetch_rows("SpellMisc", args.build, MISC_COLUMNS)
        duration_rows = fetch_rows("SpellDuration", args.build, DURATION_COLUMNS)

    try:
        output = build_lua_module(effect_rows, name_rows, misc_rows, duration_rows, args.build)
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(output, encoding="utf-8", newline="\n")
    except (OSError, ValueError) as error:
        print(f"Error: {error}", file=sys.stderr)
        return 1

    spell_count = output.count("\t\t[")
    print(f"Wrote {spell_count} spells to {args.output}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except RuntimeError as error:
        print(f"Error: {error}", file=sys.stderr)
        raise SystemExit(1)
