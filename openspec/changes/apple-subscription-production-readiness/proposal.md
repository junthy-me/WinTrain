## Why

当前 WinTrain 已具备 StoreKit 2 客户端入口、后端订阅激活/恢复接口壳和手工本地测试入口，但真实 Apple 生产闭环仍未完成。需要把这些外部资源和联调事项从现有 MVP change 中拆出，单独作为 follow-up 追踪。

## What Changes

- 建立真实 Apple 订阅生产接入的 follow-up change
- 覆盖 App Store Connect 产品、receipt 校验、Server Notifications V2、真机联调
- 覆盖本地 StoreKit 自动化测试稳定性问题的进一步排查

## Capabilities

### New Capabilities
- `apple-subscription-production-readiness`: WinTrain 订阅链路的真实 Apple 资源接入、生产校验与完整验证

### Modified Capabilities

（无）

## Impact

- App Store Connect 订阅产品配置
- Apple receipt / notification 校验策略
- `ios/WinTrainStoreKitTests/`
- 后端订阅校验与通知处理模块
- 文档：`ios/StoreKitLocalTesting.md`
