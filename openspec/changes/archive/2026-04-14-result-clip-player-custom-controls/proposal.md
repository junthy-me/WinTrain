## Why

分析结果页中的“查看问题片段”当前使用系统 `VideoPlayer`。系统播放器内置控制层无法按产品要求自定义倍速菜单标题、选项列表与顺序，也无法稳定保证后续文案与视觉细节可控。现在需要为结果页的问题片段回放提供一个轻量自定义播放器，以支持中文倍速菜单、指定倍速项，以及后续继续按设计稿微调控制层。

## What Changes

- 将分析结果页的问题片段播放页从系统 `VideoPlayer` 切换为基于 `AVPlayer` 的轻量自定义播放器界面。
- 提供当前场景需要的基础控制：播放/暂停、前进/后退 10 秒、进度拖动、完成关闭、倍速选择。
- 倍速菜单标题改为中文“倍速”，选项固定为 `0.25x`、`0.5x`、`1x`、`1.25x`、`1.5x`，并按该顺序展示。

## Capabilities

### Modified Capabilities

- `result-display`: 分析结果页的问题片段回放交互从系统默认控制层升级为产品可控的自定义播放控制层。

### New Capabilities

None.

## Impact

- Affected code: `ios/WinTrain/Views/ResultView.swift`
- Systems: iOS SwiftUI client only
- Dependencies: 继续使用系统 `AVPlayer` / `AVFoundation`，不引入第三方播放器依赖
