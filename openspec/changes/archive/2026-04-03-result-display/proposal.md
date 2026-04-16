## Why

分析结果页、状态展示和本地写入已经在 iOS 端实现，但没有对应的 OpenSpec change 工件。需要把这部分已落地能力补回流程，确保结果展示行为可追踪。

## What Changes

- 为分析结果展示和本地成功结果写入补齐 OpenSpec 工件
- 记录成功、低置信度、失败三类结果在客户端的展示边界
- 明确结果页与历史详情的复用关系

## Capabilities

### New Capabilities
- `result-display`: WinTrain MVP 的分析结果展示与本地结果呈现

### Modified Capabilities

（无）

## Impact

- iOS：`ios/WinTrain/Views/ResultView.swift`
- iOS：`ios/WinTrain/Views/AnalyzingView.swift`
- iOS：历史详情页复用结果展示
