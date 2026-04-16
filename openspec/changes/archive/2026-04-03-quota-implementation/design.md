## Context

该 change 对应 `recommended-first-changes.md` 中的 `010-quota-implementation`。当前配额逻辑已在后端和 iOS 两侧落地。

## Goals / Non-Goals

**Goals**
- 固化配额裁决与客户端展示边界
- 记录成功才扣减的实现规则

**Non-Goals**
- 不修改既定免费规则
- 不处理更复杂的订阅分层权益

## Decisions

### D1. 后端做最终裁决

分析请求进入后端时进行最终配额检查和扣减。

### D2. 客户端维护短期快照

iOS 保存短期 quota snapshot，用于快速 UI 展示与页面刷新。

### D3. 配额扣减依赖分析结果状态

只有 `success` 触发扣减，`low_confidence` 与 `failed` 保持额度不变。

## Risks / Trade-offs

- 快照可能短暂滞后，但最终以服务端状态为准

## Open Questions

- 后续若支持更多权益层级，quota snapshot 字段可能继续扩展
