# WinTrain iOS

本目录包含 WinTrain MVP 的 SwiftUI 工程骨架。

## 生成 Xcode 工程

```bash
cd ios
xcodegen generate
```

生成后会得到 `WinTrain.xcodeproj`。

## 当前状态

- 已落地 SwiftUI Tab 骨架
- 已落地网络层、Keychain 安装标识、本地历史和配额快照服务接口
- 订阅接口与上传接口已对齐 backend contract
- 购买与视频录制仍需在真机/Xcode 环境下补完整联调
