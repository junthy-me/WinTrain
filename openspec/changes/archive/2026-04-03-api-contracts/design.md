## Context

该 change 对应 `recommended-first-changes.md` 中的 `002-api-contracts`。接口文档和实现已经存在，但此前没有补到 OpenSpec 流程里。

当前事实源包括：
- `docs/contracts/video-upload-api.md`
- `docs/contracts/analysis-api.md`
- `docs/contracts/quota-api.md`
- `docs/contracts/subscription-api.md`
- `docs/contracts/error-codes.md`
- `backend/internal/httpapi/server.go`
- `ios/WinTrain/Services/APIClient.swift`

## Goals / Non-Goals

**Goals**
- 把现有 API 契约补回 OpenSpec artifacts
- 明确分析接口的三态结果与错误语义
- 明确上传、配额、订阅接口的请求/响应边界

**Non-Goals**
- 不改动既有 API 实现
- 不引入新的业务能力
- 不处理 Apple 真实订阅联调资源

## Decisions

### D1. 以现有合同文档和实现为准回填 OpenSpec

本 change 不重新设计接口，而是把已经落地的文档与代码抽象为 proposal/design/specs/tasks。

### D2. 分析接口维持三态结果模型

分析结果分为：
- `success`
- `low_confidence`
- `failed`

其中只有 `success` 会触发免费额度扣减；其余两态不扣减。

### D3. 配额接口维持服务端裁决、客户端快照展示

客户端通过 `GET /v1/quota` 获取快照；真正能否分析由后端在提交分析时最终裁决。

### D4. 订阅接口维持“客户端发起，服务端登记”模型

MVP 中客户端通过 StoreKit 2 获取交易信息，再调用后端进行订阅激活或恢复登记。真实 Apple 校验链路留给后续联调。

## Risks / Trade-offs

- 现有 API 仍属 MVP 形态，后续如果引入对象存储、云同步、真实 Apple 校验，合同需要继续演进
- 当前 change 是回填工件，不代表所有接口都已经完成长期稳定承诺

## Open Questions

- 真正的 Apple receipt / Server Notifications 校验方式仍未定稿
- 视频上传是否切换到对象存储直传仍保留扩展空间
