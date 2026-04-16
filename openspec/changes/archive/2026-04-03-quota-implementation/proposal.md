## Why

服务端配额裁决、客户端快照展示和成功才扣减的规则已经实现，但此前没有作为独立的 OpenSpec change 回填。需要把当前配额系统实现纳入流程，并准确反映已完成与依赖条件。

## What Changes

- 为配额系统实现补齐 OpenSpec 工件
- 记录服务端原子裁决、客户端快照缓存和免费规则落地
- 明确配额与分析结果状态之间的关系

## Capabilities

### New Capabilities
- `quota-implementation`: WinTrain MVP 的免费额度裁决与客户端配额快照实现

### Modified Capabilities

（无）

## Impact

- 后端：`GET /v1/quota`
- 后端：分析时配额裁决逻辑
- iOS：`QuotaStore`
- 文档：`docs/architecture/entitlement-system.md`
