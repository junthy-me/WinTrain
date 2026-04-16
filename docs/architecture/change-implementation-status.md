# Recommended Changes 实施状态

## 当前口径

- `001-system-architecture`: 已完成，已补齐输出文档
- `004a-llm-spike`: 已完成主验证；`Gemini` 对照已标记为可选延期
- `002-api-contracts`: 本轮补齐
- `005-entitlement-and-subscription-design`: 本轮补齐
- `003a-domain-models`: 本轮补齐
- `003b-storage-models`: 本轮补齐
- `006-ios-project-init`: 已补齐 SwiftUI 工程骨架与 `xcodeproj`
- `007-backend-project-init`: 已补齐 Go HTTP 服务、日志、`/health`
- `008-video-upload`: 已补齐后端上传入口与 iOS 上传服务骨架
- `009-analysis-service`: 已补齐关键帧抽取、mock provider、OpenAI-compatible provider 壳
- `010-quota-implementation`: 已补齐服务端配额裁决、`GET /v1/quota`、iOS 配额快照存储
- `011-result-display`: 已补齐结果页与成功结果本地写入
- `012-subscription-implementation`: 已补齐前后端接口壳，真实 Apple 集成受外部资源阻塞
- `013-history-feature`: 已补齐本地历史列表、动作筛选和详情复用结果页

## 已验证

- `backend`: `/usr/local/go/bin/go build ./...`
- `backend`: `/usr/local/go/bin/go test ./...`
- `backend`: `GET /health`、`GET /v1/quota`、`POST /v1/analysis` smoke 通过
- `ios`: `swiftc -typecheck` 通过
- `ios`: `xcodegen generate` 已生成 `WinTrain.xcodeproj`
- `fe`: `npm run build` 通过
- `fe`: `npm run lint` 通过

## 延期/阻塞记录

### 004a Gemini 对照

- 状态：可选延期
- 原因：不阻塞当前主流程推进
- 后续动作：在后续优化阶段补跑对照测试，并更新 `docs/architecture/llm-integration.md`

### 012 Apple 订阅资源

- 状态：外部资源阻塞，已跳过真实联调
- 原因：真实购买/恢复购买需要 App Store Connect 产品、Apple 订阅配置、服务端校验凭据
- 明天你需要做的事：
  1. 在 App Store Connect 创建订阅产品，例如 `wintrain.pro.monthly`
  2. 准备后端订阅校验所需的 Apple 凭据，并决定使用的校验方式
  3. 为 Apple Server Notifications V2 配置回调地址与签名验证材料
  4. 在真机和完整 Xcode 环境中补跑 StoreKit 购买、恢复购买、退款回退链路

### 012 本地 StoreKit 测试

- 状态：工程与手工本地测试入口已就绪；命令行自动化仍受 Apple 本地 StoreKit 运行时阻塞
- 已完成：
  1. `StoreKitCoordinator` 已切换为真实 StoreKit 2 客户端，并抽到 `WinTrainStoreKitSupport` framework，便于独立测试
  2. Paywall 已接入“加载产品 / 本地购买 / 本地恢复购买”入口
  3. `xcodebuild -runFirstLaunch` 已完成，`xcodebuild -list` 恢复可用
  4. `WinTrain` app 可正常 `xcodebuild build`
  5. 已新增 `WinTrainStoreKitTests`，并改为 logic test，覆盖购买、恢复购买、续费、退款四条路径
- 当前阻塞：
  1. `SKTestSession` 在自动化测试里仍会记录 `SKInternalErrorDomain Code=3`
  2. `session.buyProduct(identifier:)` 在 off-device buy mode 下返回 `notEntitled`
  3. 因此购买、恢复、续费、退款自动化链路还不能算跑通
- 下一步：
  1. 先通过 Xcode UI + `WinTrain` scheme 手工验证购买、恢复、续费、退款
  2. 如果后续仍需要命令行自动化，再继续排查 `notEntitled` 的 Apple 本地运行时权限问题
  3. 当前不再把命令行自动化作为主流程阻塞项
- 参考说明：
  [StoreKitLocalTesting.md](/Users/junthy/Work/WinTrain/ios/StoreKitLocalTesting.md)
