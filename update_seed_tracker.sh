#!/usr/bin/env bash
# update_seed_tracker.sh — Auto-generate seed usage tracker from .run.json files
set -e
DIR="$(cd "$(dirname "$0")" && pwd)"
OUT="$DIR/seed_tracker.txt"

echo "SOPH V2 — Seed Usage Tracker" > "$OUT"
echo "Updated: $(date -u '+%Y-%m-%d %H:%M UTC')" >> "$OUT"
echo "================================================================" >> "$OUT"

# Collect all seeds and their categories
python3 - "$DIR" "$OUT" << 'PYEOF'
import json, os, sys, glob
from collections import defaultdict

base = sys.argv[1]
out_path = sys.argv[2]

suites = ["smallcrush", "crush", "bigcrush", "nist", "dieharder", "practrand"]

# seed -> { suite -> [verdict, ...] }
seed_map = defaultdict(lambda: defaultdict(list))

# category rules
def categorise(seed_hex):
    n = len(seed_hex)
    if n <= 4:
        return "low-entropy"
    if n <= 8:
        return "short"
    if n == 32:
        return "128-bit"
    if n == 48:
        return "192-bit"
    if n == 64:
        return "256-bit"
    if n == 128:
        return "512-bit"
    return f"{n*4}-bit"

for suite in suites:
    pattern = os.path.join(base, suite, "*.run.json")
    for f in sorted(glob.glob(pattern)):
        try:
            d = json.load(open(f))
            r = d.get("result", {})
            verdict = r.get("verdict", "?")
            # extract seed from filename
            bn = os.path.basename(f)
            if "seed_" in bn:
                seed = bn.split("seed_")[1].replace(".run.json", "")
            else:
                seed = "unknown"
            seed_map[seed][suite].append(verdict)
        except:
            pass

# Group by category
cat_seeds = defaultdict(list)
for seed in sorted(seed_map.keys()):
    cat = categorise(seed)
    cat_seeds[cat].append(seed)

lines = []

# Summary table
lines.append("")
lines.append("SUMMARY BY CATEGORY")
lines.append("-" * 70)
lines.append(f"{'Category':<20s} {'Seeds':>6s} {'Tests':>6s} {'Pass':>6s} {'Warn':>6s} {'Fail':>6s}")
lines.append(f"{'-'*20:<20s} {'-'*6:>6s} {'-'*6:>6s} {'-'*6:>6s} {'-'*6:>6s} {'-'*6:>6s}")

for cat in ["low-entropy", "short", "128-bit", "192-bit", "256-bit", "512-bit"]:
    if cat not in cat_seeds:
        continue
    seeds = cat_seeds[cat]
    total_tests = 0
    total_pass = 0
    total_warn = 0
    total_fail = 0
    for seed in seeds:
        for suite, verdicts in seed_map[seed].items():
            for v in verdicts:
                total_tests += 1
                if v == "PASS": total_pass += 1
                elif v == "WARN": total_warn += 1
                elif v == "FAIL": total_fail += 1
    lines.append(f"{cat:<20s} {len(seeds):>6d} {total_tests:>6d} {total_pass:>6d} {total_warn:>6d} {total_fail:>6d}")

lines.append("")

# Per-battery seed lists
for suite in suites:
    suite_seeds = []
    for seed in sorted(seed_map.keys()):
        if suite in seed_map[seed]:
            verdicts = seed_map[seed][suite]
            cat = categorise(seed)
            suite_seeds.append((cat, seed, verdicts))

    if not suite_seeds:
        continue

    lines.append(f"{'=' * 70}")
    lines.append(f"  {suite.upper()} — {len(suite_seeds)} seeds tested")
    lines.append(f"{'=' * 70}")
    lines.append(f"{'Category':<16s} {'Seed':<68s} {'Verdict':>8s}")
    lines.append(f"{'-'*16:<16s} {'-'*68:<68s} {'-'*8:>8s}")

    for cat, seed, verdicts in sorted(suite_seeds, key=lambda x: (x[0], x[1])):
        display_seed = seed if len(seed) <= 64 else seed[:60] + "..."
        for v in verdicts:
            lines.append(f"{cat:<16s} {display_seed:<68s} {v:>8s}")
    lines.append("")

with open(out_path, "a") as f:
    f.write("\n".join(lines) + "\n")

print(f"Seed tracker updated: {len(seed_map)} unique seeds across {sum(len(v) for v in cat_seeds.values())} entries")
PYEOF

cat "$OUT"
