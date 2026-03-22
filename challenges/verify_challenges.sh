#!/usr/bin/env bash
# Verify challenge file integrity against committed hashes.
set -euo pipefail
cd "$(dirname "$0")"

PASS=0
FAIL=0

for f in challenge_2_public.bin challenge_3_gapped.bin challenge_4_output.bin; do
    hash_file="${f}.sha256"
    if [ ! -f "$hash_file" ]; then
        echo "  SKIP  $f (no hash file)"
        continue
    fi
    expected=$(cat "$hash_file" | tr -d '[:space:]')
    if [ ! -f "$f" ]; then
        echo "  MISS  $f (not downloaded yet)"
        continue
    fi
    actual=$(shasum -a 256 "$f" | awk '{print $1}')
    if [ "$actual" = "$expected" ]; then
        echo "  OK    $f"
        PASS=$((PASS + 1))
    else
        echo "  FAIL  $f (expected $expected, got $actual)"
        FAIL=$((FAIL + 1))
    fi
done

echo ""
echo "Sealed envelope hash:"
echo "  Committed: $(cat sealed_envelope.sha256 2>/dev/null || echo 'not found')"
if [ -f sealed_envelope.json ]; then
    echo "  Computed:  $(shasum -a 256 sealed_envelope.json | awk '{print $1}')"
else
    echo "  (envelope not yet published — will be revealed after deadline)"
fi

echo ""
echo "Verified: $PASS passed, $FAIL failed"
