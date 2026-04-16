## Why

`llm-spike` 已完成主路径验证并支持当前 MVP 推进，但仍有两类后续工作没有纳入新的 change：Gemini 对照实验，以及围绕 schema 稳定性、时间戳精度、时延的后续优化验证。需要把这些延后项单独跟踪，而不是继续挂在原始 spike 上。

## What Changes

- 建立 LLM 后续评估与优化的 follow-up change
- 覆盖 Gemini 视频输入对照测试
- 覆盖 schema、时间戳与时延的后续优化验证

## Capabilities

### New Capabilities
- `llm-evaluation-followups`: WinTrain LLM 路线的后续对照实验与优化验证

### Modified Capabilities

（无）

## Impact

- `backend/poc/llm-spike/`
- `docs/architecture/llm-integration.md`
- 潜在影响 `analysis-service` 的后续 provider 与预处理优化路线
