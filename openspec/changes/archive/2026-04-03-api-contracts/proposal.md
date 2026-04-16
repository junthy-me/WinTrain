## Why

系统架构与 LLM Spike 已经完成，iOS 与 Go 后端之间的核心接口也已在实现和文档中落地，但对应的 OpenSpec change 尚未补齐。需要把现有 API 约定补回到 OpenSpec 流程中，作为后续验证与归档的事实源。

## What Changes

- 为 WinTrain MVP v1 已落地的上传、分析、配额、订阅、错误处理接口补齐 OpenSpec 工件
- 将现有 `docs/contracts/*.md` 中的接口约定回填为可验证的 spec-driven artifacts
- 明确 API 的请求/响应结构、状态三态、错误码和客户端兼容边界

## Capabilities

### New Capabilities
- `api-contracts`: iOS 客户端与 Go 后端之间的 HTTP 接口契约，覆盖上传、分析、配额、订阅与错误语义

### Modified Capabilities

（无）

## Impact

- 文档：`docs/contracts/video-upload-api.md`
- 文档：`docs/contracts/analysis-api.md`
- 文档：`docs/contracts/quota-api.md`
- 文档：`docs/contracts/subscription-api.md`
- 文档：`docs/contracts/error-codes.md`
- 后端：`backend/internal/httpapi/`
- iOS：`ios/WinTrain/Services/`
