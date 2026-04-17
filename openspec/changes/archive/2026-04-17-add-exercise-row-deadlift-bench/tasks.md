## 1. iOS 动作目录（AppModels.swift）

- [x] 1.1 在 `Exercise.supported` 中追加 `bench-press` 条目（name、targets、cameraHint、imageAssetName、defaultWeight、defaultReps）
- [x] 1.2 在 `Exercise.supported` 中追加 `barbell-row` 条目
- [x] 1.3 在 `Exercise.supported` 中追加 `deadlift` 条目

## 2. GuideView 拍摄引导文案

- [x] 2.1 将 `cameraHeight` 计算属性改为 `switch exercise.id`，覆盖全部五个动作（squat / lat-pulldown / bench-press / barbell-row / deadlift）
- [x] 2.2 将 `requirements` 计算属性改为 `switch exercise.id`，为每个动作提供专属画面要求列表

## 3. 图片资产

- [x] 3.1 新建 `Assets.xcassets/BenchPressGuide.imageset/Contents.json`（格式与 LatPulldownGuide 一致）
- [x] 3.2 新建 `Assets.xcassets/BarbellRowGuide.imageset/Contents.json`
- [x] 3.3 新建 `Assets.xcassets/DeadliftGuide.imageset/Contents.json`
- [x] 3.4 在 `fe/generate-images.js` 中补充 `bench-press`、`barbell-row`、`deadlift` 三个动作的示意图生成 prompt
- [x] 3.5 使用生成的 prompt 生成三张示意图，放入对应 imageset 目录，文件名写入 Contents.json

## 4. 验证

- [x] 4.1 Xcode 编译通过，无 missing asset 警告
- [x] 4.2 SelectionView 展示五个动作卡片，新三个动作名称、目标肌群、视角提示正确
- [x] 4.3 每个新动作的 GuideView 显示正确的镜头高度和画面要求
- [x] 4.4 选择新动作后能正常进入拍摄流程并调用 `/v1/analysis`（exerciseID 正确传递）
