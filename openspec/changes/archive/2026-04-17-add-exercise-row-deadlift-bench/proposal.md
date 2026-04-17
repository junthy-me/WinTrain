## Why

MVP 当前仅支持深蹲和高位下拉两个动作，无法覆盖常见力量训练复合动作。后端已就绪（prompt、mock、路由、ID 白名单均支持五个动作），本次补齐 iOS 侧，让用户能在动作选择列表中看到并使用杠铃划船、杠铃硬拉、杠铃卧推。

## What Changes

- iOS `Exercise.supported` 新增三个条目：`barbell-row`、`deadlift`、`bench-press`，包含名称、目标肌群、拍摄视角、默认重量/次数、图资产引用
- `GuideView` 的 `cameraHeight` 和 `requirements` 两处 exercise-id 硬编码分支，扩展覆盖新增三个动作
- Xcode Assets.xcassets 新增三个 `.imageset`（`BarbellRowGuide`、`DeadliftGuide`、`BenchPressGuide`）及对应示意图

不含后端变更（后端已完整支持全部五个 exercise ID）。

## Capabilities

### New Capabilities

- `exercise-catalog`: iOS 端动作目录——Exercise 数据模型字段定义、已支持动作列表（含 ID、中文名、目标肌群、拍摄提示、图资产引用）、以及 GuideView 各动作的镜头高度和画面要求文案规则

### Modified Capabilities

- `analysis-service`: 已支持 exercise ID 列表从 2 个扩展到 5 个（`squat`、`lat-pulldown`、`bench-press`、`barbell-row`、`deadlift`）

## Impact

- `ios/WinTrain/Models/AppModels.swift`：`Exercise.supported` 数组
- `ios/WinTrain/Views/GuideView.swift`：`cameraHeight`、`requirements` 两个计算属性
- `ios/WinTrain/Assets.xcassets/`：三组新 imageset 目录及图片文件
- `openspec/specs/analysis-service/spec.md`：更新 exercise ID 枚举
