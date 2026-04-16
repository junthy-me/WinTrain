## Why

配额、设备身份、订阅恢复和本地快照策略已经在文档与代码中成型，但此前没有通过 OpenSpec change 固化。需要把这一组权益设计补回流程中，明确哪些已经实现，哪些仍受 Apple 外部资源阻塞。

## What Changes

- 为现有权益系统设计补齐 OpenSpec 工件
- 记录设备身份、免费额度规则、恢复锚点、客户端快照与服务端裁决的统一设计
- 明确本地 StoreKit 测试和真实 Apple 集成的边界，并将生产接入问题拆分到 follow-up change `apple-subscription-production-readiness`

## Capabilities

### New Capabilities
- `entitlement-system`: WinTrain MVP 的设备身份、免费额度、订阅状态与恢复购买设计

### Modified Capabilities

（无）

## Impact

- 文档：`docs/architecture/entitlement-system.md`
- 文档：`docs/architecture/subscription-flow.md`
- 文档：`ios/StoreKitLocalTesting.md`
- 文档：`docs/architecture/change-implementation-status.md`
- iOS：`ios/WinTrainStoreKitSupport/StoreKitCoordinator.swift`
- 后端：`backend/internal/httpapi/server.go`
