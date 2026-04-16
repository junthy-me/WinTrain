## 1. 权益系统设计文档

- [x] 1.1 整理设备身份方案到 `docs/architecture/entitlement-system.md`
- [x] 1.2 整理免费额度规则到 `docs/architecture/entitlement-system.md`
- [x] 1.3 整理订阅恢复锚点与状态流转到 `docs/architecture/subscription-flow.md`
- [x] 1.4 整理客户端快照与服务端裁决边界

## 2. 本地与服务端实现

- [x] 2.1 在 iOS 中实现 `install_id` 存储和 StoreKit 协调器骨架
- [x] 2.2 在后端中实现配额快照与订阅激活/恢复接口壳
- [x] 2.3 记录本地 StoreKit 测试现状与已知阻塞

## 3. 范围边界与 follow-up

- [x] 3.1 将真实 Apple receipt / notification 集成转移到 `apple-subscription-production-readiness`
- [x] 3.2 将命令行 StoreKit 自动化稳定性问题转移到 `apple-subscription-production-readiness`

## 4. OpenSpec 工件补齐

- [x] 4.1 创建 `entitlement-and-subscription-design` change proposal
- [x] 4.2 创建 `entitlement-and-subscription-design` change design
- [x] 4.3 创建 `entitlement-system` delta spec
- [x] 4.4 创建 tasks 并回填当前状态
