# Specialized Prompt Stability Comparison

This note compares the new action-specific prompts against the existing generic prompt runs on `qwen3.5-flash`.

## Prompt Files

- Generic prompt: `prompts/analysis_v1.txt`
- Squat-specific prompt: `prompts/analysis_squat_v1.txt`
- Lat pulldown-specific prompt: `prompts/analysis_lat_pulldown_v1.txt`

## Run Sets

- Generic flash baseline:
  - `testdata/llm_responses_flash/` for `S1` and `S2`
  - `testdata/llm_responses_flash_eval/` for one additional `S1/S2/S3` readout
- Specialized flash runs:
  - `testdata/llm_responses_flash_specialized/`

Assumption used in the specialized run:

- `S1` and `S3` use the squat-specific prompt
- `S2` uses the lat-pulldown-specific prompt
- `S3` was mapped to squat because prior generic results repeatedly described a missing squat bottom position

## Latency

| run set | calls | avg latency | min | max | threshold |
|--------|-------|-------------|-----|-----|-----------|
| generic flash | 6 | 38.5s | 24.2s | 51.9s | 30.0s |
| specialized flash | 9 | 15.2s | 5.0s | 36.0s | 30.0s |

Important caveat:

- the specialized average is helped by shorter outputs and a few very short low-confidence / failed responses
- so the latency win is real in aggregate, but should not be interpreted as guaranteed action-model speedup without more samples

## Schema Stability

| run set | compliant / total | rate |
|--------|--------------------|------|
| generic flash | 5 / 6 | 83.3% |
| specialized flash | 9 / 9 | 100.0% |

## Per-Sample Stability

### S1

Generic flash main outcomes:

- `足跟稳定性不足`
- `颈椎偏离中立位`
- `躯干过度前倾`

Specialized flash outcomes:

- `low_confidence`: says the video lacks a barbell and cannot assess bar path
- `success`: `躯干前倾过大` + `起身先抬臀`
- `failed`: says the video is a bodyweight squat and not a barbell squat

Interpretation:

- Stability is worse with the current squat-specific prompt.
- Root cause is prompt / sample mismatch: the prompt is written for **barbell squat**, but `S1` appears to be a bodyweight squat video.
- The prompt became more “strict”, but not more useful for this sample.

### S2

Generic flash main outcomes:

- `躯干过度后仰借力`
- `动作启动顺序错误`
- `头部前伸 / 头部跟随移动`
- `耸肩代偿`

Specialized flash outcomes:

- run 1: `耸肩代偿` + `躯干后倾借力` + `下放阶段失控`
- run 2: `后仰借力` + `启动顺序错误` + `背部收缩不充分`
- run 3: `启动顺序错误` + `后仰借力` + `回程失控`

Interpretation:

- Stability is clearly better with the lat-pulldown-specific prompt.
- Across all 3 runs, the core issues remain inside the same cluster:
  - `后仰借力`
  - `启动顺序错误 / 耸肩代偿`
  - eccentric control problems
- This is more useful than the generic prompt, which drifted more often into neck / head descriptions.

### S3

Generic flash outcome available:

- one prior run returned `low_confidence` because the squat bottom position was not fully recorded

Specialized flash outcomes:

- run 1: `low_confidence`
- run 2: `success` with `膝盖内扣` + `起身先抬臀`
- run 3: `low_confidence`

Interpretation:

- Stability is mixed.
- The specialized squat prompt still produces the desired `low_confidence` in `2/3` runs, but one run over-commits and returns concrete squat faults.
- This means the low-confidence boundary is still not fully stable for poor-quality squat-like samples.

## Bottom Line

1. The lat-pulldown-specific prompt is an improvement over the generic prompt in both focus and stability.
2. The squat-specific prompt is too tightly coupled to **barbell squat** and performs poorly on the current `S1` sample.
3. If we keep using a specialized squat prompt, we should either:
   - replace `S1` with an actual barbell squat video, or
   - loosen the prompt to allow “squat-like lower body pattern” analysis when no barbell is present.
