## Context

当前 MVP 范围内的订阅入口、权益设计和手工本地验证都已落地。剩余问题主要集中在两类：
- Apple 外部资源尚未提供完整生产接入条件
- 本地 StoreKit 命令行自动化仍被 `SKInternalErrorDomain Code=3` / `notEntitled` 阻塞

## Goals / Non-Goals

**Goals**
- 独立跟踪真实 Apple 订阅生产接入工作
- 独立跟踪本地 StoreKit 自动化稳定性问题

**Non-Goals**
- 不重复实现已有的 StoreKit 2 客户端入口和后端激活/恢复接口壳
- 不重写现有权益规则

## Decisions

### D1. 生产 Apple 资源与 MVP 本地实现分离追踪

MVP 本地可运行入口已经具备，生产 Apple 接入单独作为 follow-up change 管理。

### D2. 自动化与手工验证分离

在 CLI 自动化未跑通前，手工 Xcode 本地验证继续作为当前可行路径；自动化稳定性单独排查。

## Risks / Trade-offs

- Apple 资源申请与审批节奏不受代码仓库控制
- 本地 StoreKit 自动化问题可能与 Xcode / Simulator 运行时相关，而非项目代码本身

## Open Questions

- 最终采用哪种 receipt 校验路径
- CLI StoreKit 自动化是否需要切换到不同测试形态或工具链
