# SOPH Randomness Challenge — Round 1

Four independent challenges testing the statistical and cryptographic quality of SOPH V3 output. No knowledge of the internal architecture is required or provided.

**Deadline:** September 22, 2026 (6 months from publication)

**After deadline:** The sealed envelope will be published, revealing seeds, assignments, and answers. Anyone can verify the SHA-256 hash matches the one committed at challenge creation.

---

## Challenge 1: Indistinguishability

**Difficulty:** Hard

A 10 GiB binary file containing interleaved 1 MiB chunks. Some chunks are from SOPH V3, others from `/dev/urandom`. Your task: identify which chunks came from which source.

- **File:** `challenge_1_mixed.bin` (S3)
- **Chunk size:** 1,048,576 bytes (1 MiB)
- **Total chunks:** 10,240
- **Submission:** A list of 10,240 labels (`soph` or `urandom`), one per chunk

---

## Challenge 2: Prediction

**Difficulty:** Extreme

1 GiB of sequential SOPH V3 output. Your task: predict the next 16 bytes.

- **File:** `challenge_2_public.bin` (S3)
- **File size:** 1,073,741,824 bytes (exactly 1 GiB)
- **Submission:** 16 bytes (32 hex characters) — the predicted bytes at position 1,073,741,824 through 1,073,741,839
- **Probability of random guess:** 1 in 2^128

---

## Challenge 3: Interpolation

**Difficulty:** Extreme

1 GiB of SOPH V3 output with 1,024 gaps of 16 bytes each. Gaps are located at the midpoint of each 1 MiB block (offset 524,288 within each block). The gap bytes are replaced with zeros. Your task: reconstruct the original bytes at any single gap.

- **File:** `challenge_3_gapped.bin` (S3)
- **Gap positions:** byte offset `(i * 1048576) + 524288` for i = 0..1023
- **Gap size:** 16 bytes per gap
- **Submission:** The gap index (0-1023) and 16 bytes (32 hex characters)

---

## Challenge 4: Architecture Recovery

**Difficulty:** Open-ended

The seed and 1 GiB of output are both provided. Your task: describe any component of the algorithm that produced this output from this seed.

- **Seed:** `d8eaf1032c4b567890abcdef12345678fedcba9876543210aabbccdd11223344`
- **File:** `challenge_4_output.bin` (S3)
- **Submission:** A description of any internal mechanism (e.g., block cipher type, hash function used, state size, mixing strategy, or any structural property) supported by evidence from your analysis

---

## Verification

All challenge files are accompanied by SHA-256 hashes in this repository. After downloading from S3, verify integrity:

```bash
./verify_challenges.sh
```

The sealed envelope hash was committed at challenge creation. After the deadline, the full envelope will be published. Verify:

```bash
shasum -a 256 sealed_envelope.json
# Must match: sealed_envelope.sha256
```

---

## Submission Process

1. Open a GitHub Issue in this repository
2. Title: `Challenge [N] Submission — [Your Name/Handle]`
3. Include:
   - Which challenge you are attempting
   - Your methodology (description + code)
   - Your answer
4. We will verify your submission and respond publicly

---

## File Hashes

| File | SHA-256 |
|------|---------|
| `challenge_2_public.bin` | `48d6257439e060d98d220ea904e4513d0b0540ac48688c84632d0644f561f383` |
| `challenge_3_gapped.bin` | `85250238210d14778d6fe4c78470957a0098905748fbb18842f8ef280ee03899` |
| `challenge_4_output.bin` | `d096d825c1e27d7c83e59e0afb1e6959a76b064465e478fe4ebecb1663daee2c` |

**Sealed Envelope Hash:** `8d09824a875024fffb683e015ff1c59454803fe3bd308978ca3e5533f1dcc6ac`

---

## S3 Download

```bash
# Challenge files hosted at:
# https://soph-entropy-challenges.s3.amazonaws.com/v3-round1/

wget https://soph-entropy-challenges.s3.amazonaws.com/v3-round1/challenge_2_public.bin
wget https://soph-entropy-challenges.s3.amazonaws.com/v3-round1/challenge_3_gapped.bin
wget https://soph-entropy-challenges.s3.amazonaws.com/v3-round1/challenge_4_output.bin
```

---

*Published by SOPH Entropy. Challenge files generated March 22, 2026.*
