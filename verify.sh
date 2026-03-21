#!/usr/bin/env bash
# Verify all signed run records in this repo
set -e
PUBKEY="$(dirname "$0")/keys/signing-pub.pem"
if [ ! -f "$PUBKEY" ]; then echo "Public key not found: $PUBKEY"; exit 1; fi
FAILS=0
for sig in $(find . -name "*.run.json.sig" | sort); do
    record="${sig%.sig}"
    if openssl dgst -sha256 -verify "$PUBKEY" -signature "$sig" "$record" > /dev/null 2>&1; then
        echo "  ✓ $record"
    else
        echo "  ✗ FAILED: $record"
        FAILS=$((FAILS+1))
    fi
done
if [ $FAILS -eq 0 ]; then echo "All signatures verified ✓"; else echo "$FAILS signature(s) FAILED"; exit 1; fi
