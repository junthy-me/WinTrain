## Context

该 change 对应 `recommended-first-changes.md` 中的 `012-subscription-implementation`。当前已实现客户端 StoreKit 2 入口、Paywall 调用和后端激活/恢复接口壳；真实 Apple 联调与本地自动化稳定性已拆分到 follow-up change `apple-subscription-production-readiness`。

## Goals / Non-Goals

**Goals**
- 固化当前 MVP 订阅实现边界
- 记录客户端入口、后端登记接口和手工本地验证能力

**Non-Goals**
- 不覆盖真实 Apple 生产接入
- 不覆盖 CLI StoreKit 自动化稳定性排查

## Decisions

### D1. 客户端负责发起 StoreKit 购买与恢复

iOS 使用 StoreKit 2 协调器加载产品、购买和恢复购买。

### D2. 后端负责登记订阅状态

后端提供激活与恢复接口，用于接收客户端上送的交易标识并更新服务端权益状态。

### D3. 真实 Apple 接入与 CLI 自动化拆分到 follow-up change

真实 Apple receipt / notification 接入以及 CLI StoreKit 自动化问题不再挂在本 change 下，统一跟踪于 `apple-subscription-production-readiness`。

## Risks / Trade-offs

- 当前 change 不覆盖生产闭环，因此需要依赖 follow-up change 才能达到生产就绪

## Open Questions

（无，生产相关问题已转移到 follow-up change）
