# StoreKit 本地测试

## 当前状态

代码侧已经补齐：

- StoreKit 2 协调器：`ios/WinTrainStoreKitSupport/StoreKitCoordinator.swift`
- Paywall 调用入口：`ios/WinTrain/Views/PaywallView.swift`
- `SKTestSession` 自动化测试目标：`ios/WinTrainStoreKitTests/StoreKitLocalTests.swift`
- 独立的 StoreKit framework target：`WinTrainStoreKitSupport`

当前阻塞点已经缩小到 Apple 本地测试运行时本身：

- `xcodebuild build -project WinTrain.xcodeproj -scheme WinTrain` 已通过，说明工程和 framework 拆分是健康的
- `xcodebuild test -project WinTrain.xcodeproj -scheme WinTrainStoreKitTests -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.4' -only-testing:WinTrainStoreKitTests/StoreKitLocalTests/testPurchaseMonthlySubscription` 仍然失败
- 失败现象固定为两条：
  1. `SKTestSession` 初始化时记录 `SKInternalErrorDomain Code=3`
  2. `session.buyProduct(identifier:)` 返回 `notEntitled`，日志为 `Failed to purchase ... in off-device buy mode`
- 这说明问题已经不在 `.storekit` 文件是否存在、是否进包、是否挂到 scheme，而是在当前 Xcode 本地 StoreKit 自动化运行时没有给测试进程授予可执行 off-device buy 的权限

## 当前建议的验证方式

先用 Xcode UI 手工验证本地 StoreKit 流程，不依赖当前自动化测试：

1. 打开 `ios/WinTrain.xcodeproj`
2. 选择 `WinTrain` scheme，并确认 `Run > Options` 已挂载 `WinTrainLocal.storekit`
3. 运行 App 到模拟器
4. 打开 Paywall，使用页面上的“加载本地订阅产品 / 运行本地 StoreKit 购买 / 运行本地 StoreKit 恢复购买”按钮验证购买与恢复
5. 对于续费和退款，使用 Xcode 的 StoreKit Transaction Manager 手工触发

## 本地测试流程

### 购买

- 打开 Paywall
- 点击“运行本地 StoreKit 购买”
- 预期：
  - `statusMessage` 显示购买成功
  - `isSubscribed` 变为 `true`

### 恢复购买

- 清理本地应用状态后重新启动
- 点击“运行本地 StoreKit 恢复购买”
- 预期：
  - 恢复成功
  - 订阅仍然有效

### 续费

- 使用本地 StoreKit 配置运行应用
- 在 Xcode 的 StoreKit Transaction Manager 里触发续费
- 预期：
  - `Transaction.updates` 收到续费事件
  - `statusMessage` 刷新为“收到订阅更新”

### 退款 / 撤销

- 通过 Xcode 的 StoreKit Transaction Manager 触发退款
- 预期：
  - 当前 entitlement 消失
  - `isSubscribed` 变为 `false`

## 命令行自动化现状

当前自动化用例已经切到 Apple 推荐的 `SKTestSession.buyProduct(...)` 路线，但仍被本地运行时拒绝：

```bash
cd ios
xcodebuild test -project WinTrain.xcodeproj -scheme WinTrainStoreKitTests -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.4' -only-testing:WinTrainStoreKitTests/StoreKitLocalTests/testPurchaseMonthlySubscription
```

当前输出会稳定出现：

- `SKInternalErrorDomain Code=3`
- `failed: caught error: "notEntitled"`

所以当前结论是：自动化测试代码和工程形态都已经到位，但 Apple 本地 StoreKit 自动化在这台环境里尚未真正授权通过，现阶段更可靠的是用 Xcode UI 做手工本地验证。
