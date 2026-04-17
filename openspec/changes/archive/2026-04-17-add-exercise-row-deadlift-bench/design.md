## Context

后端已完整支持五个 exercise ID（`squat`、`lat-pulldown`、`bench-press`、`barbell-row`、`deadlift`）：prompt、mock provider、`promptForExercise()` 路由、`supportedExerciseID()` 白名单均已到位。缺口仅在 iOS 端：

- `Exercise.supported` 只有 `squat` 和 `lat-pulldown` 两条，新动作不会出现在选择列表
- `GuideView` 的 `cameraHeight` / `requirements` 用 if/else-if 硬写了两个分支，新动作会落入兜底逻辑（高位下拉文案）
- Assets 中没有新三个动作的示意图 imageset

本次变更范围纯 iOS，不涉及后端或 API 合约结构性变化。

## Goals / Non-Goals

**Goals:**

- 在 `Exercise.supported` 追加 `barbell-row`、`deadlift`、`bench-press` 三条条目
- 为每个新动作在 `GuideView` 中提供正确的镜头高度文案和画面要求列表
- 为三个新动作各添加一个 `*.imageset` 目录（Contents.json + 占位/正式图片）

**Non-Goals:**

- 后端代码变更（后端已就绪）
- 动作元数据改为服务端下发（当前 MVP 静态列表足够）
- GuideView 架构重构（保持现有模式，只扩展分支）
- 新动作的 demo HistoryRecord / AnalysisResult 静态数据（用不到即不加）

## Decisions

### 1. Exercise 元数据继续静态硬编码在 AppModels.swift

**选择**: 追加到 `Extension Exercise { static let supported }` 数组。

**理由**: 当前 MVP 五个动作固定，无需运行时配置；与现有两个条目完全对称，变更最小。

**放弃的方案**: 从后端 `/v1/exercises` 接口动态拉取——引入额外 API 端点、缓存、错误处理，MVP 阶段收益远不及成本。

### 2. GuideView 扩展用 switch 替换 if/else-if 链

**选择**: 将 `cameraHeight` 和 `requirements` 从 if/else-if 改为 `switch exercise.id`，每个动作一个 case，default 保留深蹲兜底。

**理由**: 五个动作后 if-else 链可读性差；switch 穷举更直观，也更容易在后续加第六个动作时发现遗漏。

**放弃的方案**: 把文案挂到 `Exercise` struct 字段上（`cameraHeightHint: String`、`requirements: [String]`）—— 虽然更"干净"，但改动了数据模型合约，超出本次范围。

### 3. Image asset 命名与格式

**选择**: 命名 `BarbellRowGuide`、`DeadliftGuide`、`BenchPressGuide`，格式与现有 `LatPulldownGuide`/`SquatGuide` 一致（universal 1x JPEG，Contents.json 留 2x/3x 空槽）。

**理由**: 与现有 asset 完全对称；AppRemoteImage 通过 `imageAssetName` 字符串查找，不需要任何代码改动。

## Risks / Trade-offs

- **[风险] GuideView 硬编码随动作数增长** → 本次变更后共五个 case，MVP 规模可接受；若后续超过八个动作再考虑数据驱动方案
- **[风险] 示意图占位** → 图片生成 prompt 已提供，上线前需完成图片生成并替换占位文件；若图片缺失 AppRemoteImage 会展示默认空状态，不会崩溃
- **[风险] Exercise.find() 兜底行为** → `find(_ id:)` 在找不到时返回 `supported[0]`（深蹲），历史记录中老数据不受影响
