## 1. Apple 生产资源

- [ ] 1.1 在 App Store Connect 创建并确认订阅产品，例如 `wintrain.pro.monthly`
- [ ] 1.2 确定并配置后端 Apple receipt 校验方案
- [ ] 1.3 配置 Apple Server Notifications V2 回调与签名验证材料

## 2. 完整联调验证

- [ ] 2.1 在真机上完成购买、恢复购买、续费、退款回退链路验证
- [ ] 2.2 验证服务端订阅状态与 Apple 状态变化能够正确对齐

## 3. 本地 StoreKit 自动化稳定性

- [ ] 3.1 继续排查 `SKInternalErrorDomain Code=3` 与 `notEntitled`
- [ ] 3.2 跑通命令行自动化的购买、恢复、续费、退款链路

## 4. OpenSpec 工件

- [x] 4.1 创建 `apple-subscription-production-readiness` change proposal
- [x] 4.2 创建 `apple-subscription-production-readiness` change design
- [x] 4.3 创建 `apple-subscription-production-readiness` delta spec
- [x] 4.4 创建 tasks
