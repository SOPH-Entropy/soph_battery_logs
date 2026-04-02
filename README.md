# SOPH Battery Test Logs

Signed, independently-verifiable results from statistical randomness test suites run against the SOPH modular CTR engine.

## Algorithm Variants

| Variant | Description | Crypto-secure |
|---------|-------------|---------------|
| `ctr` | Full extraction pipeline (default) | Yes |
| `raw` | Keyed whitening only, ~4× throughput (~100 GiB/s) | See §7.5 |
| `light` | Reduced state for constrained devices | Yes |

## Structure

```
├── keys/              # RSA-4096 public key for signature verification
├── practrand/         # PractRand results
├── dieharder/         # Dieharder results
├── nist/              # NIST STS results (arcetri/sts v3, multi-threaded)
├── smallcrush/        # TestU01 SmallCrush results
├── crush/             # TestU01 Crush results
├── bigcrush/          # TestU01 BigCrush results
└── verify.sh          # Verify all signatures
```

## Verification

Every `.run.json` record has an accompanying `.run.json.sig` (RSA-4096 + SHA-256 signature).

```bash
./verify.sh
```

## Reproducibility

Each record includes the seed, source commit, binary SHA-256, and algorithm variant. Given the same seed, variant, and binary, results are fully deterministic and reproducible across platforms (macOS/clang, Linux/gcc).
