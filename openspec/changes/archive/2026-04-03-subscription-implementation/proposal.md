## Why

订阅激活、恢复购买接口壳和 StoreKit 2 客户端入口已经实现，但真实 Apple 联调仍未完成。需要把这个 change 的当前状态回填到 OpenSpec 流程中，明确哪些任务已经落地，哪些仍受外部资源或 Apple 本地运行时阻塞。

## What Changes

- 为订阅实现补齐 OpenSpec 工件
- 记录 iOS StoreKit 2 入口、后端订阅激活/恢复接口和本地 StoreKit 测试现状
- 明确真实 Apple 生产集成与自动化稳定性工作已拆分到 follow-up change `apple-subscription-production-readiness`

## Capabilities

### New Capabilities
- `subscription-implementation`: WinTrain MVP 的客户端订阅入口与后端订阅登记实现

### Modified Capabilities

（无）

## Impact

- iOS：`ios/WinTrainStoreKitSupport/StoreKitCoordinator.swift`
- iOS：`ios/WinTrain/Views/PaywallView.swift`
- iOS：`ios/WinTrainStoreKitTests/StoreKitLocalTests.swift`
- 后端：订阅激活/恢复接口
- 文档：`ios/StoreKitLocalTesting.md`
