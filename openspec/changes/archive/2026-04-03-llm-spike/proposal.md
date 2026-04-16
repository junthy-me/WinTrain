## Why

在进入 002-api-contracts 和 003a-domain-models 的正式设计前，需要通过技术验证确认直接视频输入模型的核心假设是否成立：视觉模型能否在接收 20 秒以内的完整视频后，稳定返回符合预期结构的 JSON 分析结果、可靠区分三态、并输出足够精确的片段时间戳。这些假设若不成立，将直接影响 API Contract 的字段设计和 Domain Model 的结构定义，并决定是否需要引入预处理优化路线（抽帧 / rep 分割）。

## What Changes

- 新增 `backend/poc/llm-spike/` 目录，包含直接视频输入调用验证脚本、结构化输出解析验证脚本、延迟与成本记录脚本
- 新增 spike 验证报告，记录验证结论、发现的问题、以及对后续 change 的影响
- 不创建正式 API、正式数据库模型或正式服务层
- 不修改任何现有生产代码路径

## Capabilities

### New Capabilities

- `llm-spike`: 直接视频输入 LLM 技术验证范围、输入样本方案、Prompt 验证标准、结构化输出验证标准、延迟与成本验证标准、成功判定标准、以及 spike 失败时对 002-api-contracts 的调整建议

### Modified Capabilities

（无）

## Impact

- `backend/poc/llm-spike/`：新增验证代码，仅用于技术验证，不并入生产主链路
- `002-api-contracts`：spike 结论将直接影响分析接口的字段设计（尤其是 `clip` 时间戳精度、`low_confidence` 触发条件、`status` 三态定义）
- `003a-domain-models`：spike 结论将影响 `AnalysisResult` 和 `Feedback` 的字段类型与约束
- 外部依赖：qwen3.5-plus（主验证模型）；可选对照 Google Gemini 视频输入
