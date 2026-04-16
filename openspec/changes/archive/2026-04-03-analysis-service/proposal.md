## Why

关键帧抽取、provider 抽象、mock/openai-compatible 分析链路和结构化结果解析已经实现，但缺少对应的 OpenSpec change 工件。需要补齐流程，明确当前 MVP 分析服务的边界。

## What Changes

- 为关键帧抽取与 LLM 分析编排补齐 OpenSpec 工件
- 记录 provider 抽象、超时/失败路径和结构化结果处理
- 将已落地实现与 `llm-spike` 的验证产物衔接起来

## Capabilities

### New Capabilities
- `analysis-service`: WinTrain MVP 的关键帧抽取、LLM 调用与分析任务编排

### Modified Capabilities

（无）

## Impact

- 后端：`backend/internal/analysis/`
- 后端：provider 抽象与运行命令
- 文档：`docs/architecture/llm-integration.md`
