# WinTrain Backend

## Analysis Provider

The backend supports two analysis modes:

- `mock`: returns fixed demo analysis results
- `vision`: calls a real QWen model through DashScope's OpenAI-compatible API

The production path is aligned with the verified `poc/llm-spike` setup:

- base URL: DashScope compatible-mode endpoint
- model: `qwen3.5-plus`
- request shape: `chat/completions` with `messages[].content[]` using `type=video_url`
- current local-file path: direct base64 data URL for videos `< 7 MB`

If `WINTRAIN_ANALYSIS_MODE` is omitted, the backend now auto-switches to `vision` when it finds a provider API key. Recommended config:

```bash
export WINTRAIN_ANALYSIS_MODE=vision
export WINTRAIN_OPENAI_API_KEY=...
export WINTRAIN_OPENAI_MODEL=qwen3.5-plus
export WINTRAIN_OPENAI_BASE_URL=https://dashscope.aliyuncs.com/compatible-mode/v1
export WINTRAIN_OPENAI_VIDEO_FPS=2
```

Also supported as fallbacks:

```bash
export DASHSCOPE_API_KEY=...
export DASHSCOPE_BASE_URL=https://dashscope.aliyuncs.com/compatible-mode/v1
```

Notes:

- If `WINTRAIN_ANALYSIS_MODE=vision` is set but required variables are missing, the backend exits on startup instead of silently falling back to `mock`.
- `DASHSCOPE_API_KEY` and `DASHSCOPE_BASE_URL` are accepted as fallbacks.
- If an API key is present and no base URL is set, the backend defaults to DashScope Beijing.
- The current direct-video path follows the POC constraint: local files must be `< 7 MB`. Larger uploaded files need recompression/shortening before analysis.

## Run

```bash
cd backend
/usr/local/go/bin/go run ./cmd/api
```

On startup the backend logs the selected analysis provider, mode, model, and base URL.
