## Context

该 change 对应 `recommended-first-changes.md` 中的 `006-ios-project-init`。SwiftUI 工程、Tab 骨架、网络层和 `install_id` 基础设施已经存在。

## Goals / Non-Goals

**Goals**
- 固化 iOS 项目骨架的边界
- 明确基础应用结构与支撑服务

**Non-Goals**
- 不在本 change 中定义完整业务逻辑
- 不以此替代上传、分析、订阅等后续业务 change

## Decisions

### D1. 客户端使用 SwiftUI + iOS 16+

应用主壳采用 SwiftUI，使用 Xcode 工程和 `xcodegen` 管理配置。

### D2. 基础设施先行

`APIClient`、`InstallIDStore`、`QuotaStore` 等基础服务随骨架一起建立，供后续业务能力复用。

### D3. 页面结构采用底部 Tab

首页、历史、我的三块主导航先建立稳定入口，业务细节后续逐步补充。

## Risks / Trade-offs

- 工程初始化阶段引入的壳页面可能与最终交互继续演进

## Open Questions

- 后续是否拆分更多独立 framework 仍可根据复杂度调整
