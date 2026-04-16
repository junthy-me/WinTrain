# llm-spike

`llm-spike` is an isolated proof-of-concept workspace for validating the MVP v1 assumption that a multimodal LLM can consume a full training video directly and return structured JSON feedback without frame extraction.

## Scope

- Primary path: send a full video (`<= 20s`) directly to `qwen3.5-plus`
- Validate structured output stability, tristate behavior, timestamp usability, latency, and estimated cost
- Do not add production handlers, services, or models under `backend/internal` or production `backend/cmd`

## Directory Layout

```text
backend/poc/llm-spike/
├── README.md
├── REPORT.md
├── cmd/
│   ├── run_analysis/
│   └── validate_output/
├── internal/spike/
├── prompts/
│   └── analysis_v1.txt
├── results/
└── testdata/
    ├── annotations.json
    ├── llm_responses/
    └── samples.md
```

## Prerequisites

- Go toolchain installed locally (`go`, `gofmt`)
- A DashScope API key with access to `qwen3.5-plus`
- Three real sample videos matching the OpenSpec scenarios

Optional but recommended:

- `ffprobe` for manually checking duration and resolution before recording `samples.md`

## Official API Constraints Confirmed For This Spike

The runner uses DashScope's OpenAI-compatible `chat/completions` endpoint with `model=qwen3.5-plus`.

- Beijing base URL: `https://dashscope.aliyuncs.com/compatible-mode/v1`
- Singapore base URL: `https://dashscope-intl.aliyuncs.com/compatible-mode/v1`
- Virginia base URL: `https://dashscope-us.aliyuncs.com/compatible-mode/v1`
- Video input shape: `messages[].content[]` with `type=video_url`
- Local file strategy:
  - raw file `< 7 MB`: supported via `data:video/<mime>;base64,...`
  - raw file `>= 7 MB` and `<= 100 MB`: OpenAI-compatible mode requires a public URL
  - raw file `> 100 MB`: not supported for this spike

The cost helper defaults to the current mainland/global `qwen3.5-plus` pricing tier published by Model Studio for requests within `0 < input_tokens <= 128K`:

- input: `0.8 CNY / 1,000,000 tokens`
- output: `4.8 CNY / 1,000,000 tokens`

Override rates with environment variables if you pin another region or pricing tier.

## Environment Variables

- `DASHSCOPE_API_KEY`: required
- `DASHSCOPE_BASE_URL`: optional, defaults to Beijing
- `LLM_SPIKE_MODEL`: optional, defaults to `qwen3.5-plus`
- `LLM_SPIKE_INPUT_RATE_CNY_PER_MTOKENS`: optional, defaults to `0.8`
- `LLM_SPIKE_OUTPUT_RATE_CNY_PER_MTOKENS`: optional, defaults to `4.8`

## Prompt Review Checklist

`prompts/analysis_v1.txt` was written to satisfy the OpenSpec prompt tasks and manually reviewed against these constraints:

- Includes a complete JSON schema example
- States `only return JSON`
- Defines `low_confidence` with explicit, non-fuzzy trigger rules
- Requires numeric `clip.start_ms` and `clip.end_ms`
- Distinguishes `success`, `low_confidence`, and `failed`

## Sample Preparation

1. Collect three real videos and keep each at `<= 20s`.
2. Record metadata in `testdata/samples.md`.
3. Fill `testdata/annotations.json` with the human-labeled error clip for each sample.
4. If a video is `>= 7 MB`, upload it to a public URL and pass that URL to the runner.

Recommended sample file names:

- `poc/llm-spike/testdata/s1.mp4`
- `poc/llm-spike/testdata/s2.mp4`
- `poc/llm-spike/testdata/s3.mp4`

Annotation guidance:

- `s1`: mark the clearest error window for the primary squat issue
- `s2`: mark the clearest error window for the primary pulldown issue
- `s3`: if the video truly cannot support a reliable clip, keep the reference clip at `0/0` only as a placeholder until you decide whether to exclude it from timestamp accuracy analysis

The validator matches annotations by `sample_id`, not by filename, so the critical part is keeping `sample_id` aligned with `s1`, `s2`, and `s3`.

## Run Analysis

Single call:

```bash
cd backend
go run ./poc/llm-spike/cmd/run_analysis \
  -sample s1 \
  -video ./poc/llm-spike/testdata/s1.mp4 \
  -run-id run-01
```

Using a public video URL for larger files:

```bash
cd backend
go run ./poc/llm-spike/cmd/run_analysis \
  -sample s1 \
  -video ./poc/llm-spike/testdata/s1.mp4 \
  -video-url https://example.com/s1.mp4 \
  -run-id run-01
```

Repeat three times per sample with distinct `run-id` values. The runner writes:

- raw response envelopes under `testdata/llm_responses/<sample>/`
- aggregate call metrics to `testdata/llm_responses/call_metrics.json`

## Validate Outputs

After collecting all responses:

```bash
cd backend
go run ./poc/llm-spike/cmd/validate_output
```

The validator reads the raw responses and writes:

- `results/schema_compliance.json`
- `results/tristate_review.json`
- `results/timestamp_accuracy.json`
- `results/latency_cost.json`

## Known Stop Line

This workspace can be implemented without live samples, but these tasks remain blocked until real videos and API access are available:

- collect S1/S2/S3 videos
- annotate timestamps
- execute live calls
- fill report conclusions from measured outputs
