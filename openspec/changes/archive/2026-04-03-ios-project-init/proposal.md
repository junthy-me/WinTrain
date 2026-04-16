## Why

iOS 工程骨架已经落地，但没有对应的 OpenSpec change 记录工程初始化范围与边界。需要把现有骨架回填到流程中，明确哪些属于项目初始化，哪些属于后续业务实现。

## What Changes

- 为现有 SwiftUI iOS 工程骨架补齐 OpenSpec 工件
- 记录项目结构、基础网络层、Keychain 标识、Tab 骨架和基础页面组织
- 明确项目初始化与业务实现的边界

## Capabilities

### New Capabilities
- `ios-project-init`: WinTrain iOS 客户端的工程初始化与基础应用骨架

### Modified Capabilities

（无）

## Impact

- iOS：`ios/WinTrain.xcodeproj`
- iOS：`ios/project.yml`
- iOS：`ios/WinTrain/App/`
- iOS：`ios/WinTrain/Views/`
- iOS：`ios/WinTrain/Services/`
