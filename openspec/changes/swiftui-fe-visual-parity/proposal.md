## Why

当前 iOS 端已经具备 MVP 业务链路，但界面仍停留在系统 `List` 和默认 `TabView` 骨架，与 `fe/` 中已经确认的深色卡片式视觉稿存在明显落差。现在需要将 SwiftUI 版本重做为与 FE 视觉、交互层级和状态呈现一致的版本，同时保持现有分析、历史、订阅和配额功能语义不变。

## What Changes

- 以 SwiftUI 重构 iOS 客户端的主界面壳层、底部导航、页面头部和通用卡片样式，对齐 FE 视觉稿的深色主题和信息层级。
- 重做首页、动作选择、拍摄指南、分析中、结果页、历史、我的、订阅页的 SwiftUI 展现，使其在状态文案、分区结构和关键 CTA 上与 FE 保持一致。
- 保留现有后端 API、StoreKit 接入、本地历史、本地配额和分析流程语义，不新增或移除业务能力。

## Capabilities

### New Capabilities
- `ios-visual-parity`: 定义 iOS SwiftUI 客户端在既有 MVP 功能之上的 FE 视觉一致性要求，包括应用壳层、主要页面布局和关键状态呈现。

### Modified Capabilities

None.

## Impact

- Affected code: `ios/WinTrain/App`, `ios/WinTrain/Views`, `ios/WinTrain/ViewModels`, 以及新增的 SwiftUI 主题/通用组件。
- Systems: iOS SwiftUI client only.
- Dependencies: 继续使用现有 SwiftUI、StoreKit 和服务层，不引入新的后端依赖。
