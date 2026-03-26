# Model Comparison

This file records a supplementary comparison between the primary spike model `qwen3.5-plus` and the follow-up check `qwen3.5-flash`.

## Scope

- `qwen3.5-plus`: full primary spike over `S1/S2/S3`
- `qwen3.5-flash`: supplementary comparison over `S1/S2`

## Latency

| model | calls | avg latency | min | max | threshold |
|-------|-------|-------------|-----|-----|-----------|
| qwen3.5-plus | 9 | 64.6s | 25.6s | 120.0s | 30.0s |
| qwen3.5-flash | 6 | 38.5s | 24.2s | 51.9s | 30.0s |

Observation:

- `qwen3.5-flash` is materially faster than `qwen3.5-plus`
- but `qwen3.5-flash` still fails the `<=30s` target on average

## Schema Compliance

| model | compliant / total | rate | threshold |
|-------|-------------------|------|-----------|
| qwen3.5-plus | 7 / 9 | 77.8% | 90.0% |
| qwen3.5-flash | 5 / 6 | 83.3% | 90.0% |

Observation:

- `qwen3.5-flash` is slightly better on this smaller sample
- neither model reaches the required schema stability threshold once transport failures are counted

## Cost

| model | avg estimated cost |
|-------|--------------------|
| qwen3.5-plus | ¥0.0184 |
| qwen3.5-flash | ¥0.0241 |

Observation:

- both models are comfortably below the `¥0.20` threshold
- the blocking issue is latency and reliability, not cost

## Conclusion

Switching from `qwen3.5-plus` to `qwen3.5-flash` improves latency, but not enough to make direct full-video synchronous analysis acceptable for MVP v1.
