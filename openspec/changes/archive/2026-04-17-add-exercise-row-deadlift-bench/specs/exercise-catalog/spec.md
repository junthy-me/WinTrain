# Spec: exercise-catalog

## Purpose

定义 iOS 端动作目录——Exercise 数据结构、已支持动作列表，以及 GuideView 中各动作的拍摄引导文案规则。

## ADDED Requirements

### Requirement: The iOS app SHALL expose a static exercise catalog with five supported exercises
The iOS app SHALL maintain a static list of supported exercises. Each entry SHALL include: `id`（后端 exercise_id）、`name`（中文名）、`targets`（目标肌群）、`cameraHint`（建议拍摄视角）、`imageAssetName`（图资产名）、`defaultWeight`、`defaultReps`。

#### Scenario: Full catalog is available at launch
- **WHEN** the app launches
- **THEN** `Exercise.supported` contains exactly five entries: `squat`、`lat-pulldown`、`bench-press`、`barbell-row`、`deadlift`，顺序依次排列

#### Scenario: New exercise entry is complete
- **WHEN** a new exercise entry is added to `Exercise.supported`
- **THEN** all seven fields (`id`, `name`, `targets`, `cameraHint`, `imageAssetName`, `defaultWeight`, `defaultReps`) are non-empty strings

### Requirement: The iOS app SHALL display exercise-specific shooting guidance in GuideView
GuideView SHALL show the correct camera height hint and frame requirements for every supported exercise. Each exercise SHALL have its own distinct `cameraHeight` string and `requirements` array; no two exercises with different motion patterns SHALL share the same guidance text.

#### Scenario: Squat guidance
- **WHEN** GuideView is opened for `squat`
- **THEN** `cameraHeight` is `"髋部附近高度"`，`requirements` covers barbell、torso、hip、knee、ankle、feet visibility

#### Scenario: Lat-pulldown guidance
- **WHEN** GuideView is opened for `lat-pulldown`
- **THEN** `cameraHeight` is `"上半身到头部附近高度"`，`requirements` covers head、shoulder、elbow、bar、torso visibility

#### Scenario: Bench-press guidance
- **WHEN** GuideView is opened for `bench-press`
- **THEN** `cameraHeight` is `"凳面到头部附近高度"`，`requirements` covers barbell、wrist、elbow、shoulder、chest、bench contact visibility

#### Scenario: Barbell-row guidance
- **WHEN** GuideView is opened for `barbell-row`
- **THEN** `cameraHeight` is `"腰部附近高度"`，`requirements` covers head/neck、torso、hip、knee、shank、elbow/barbell visibility

#### Scenario: Deadlift guidance
- **WHEN** GuideView is opened for `deadlift`
- **THEN** `cameraHeight` is `"腰部到髋部附近高度"`，`requirements` covers head/neck、back、hip、knee、shank、barbell path visibility

### Requirement: Each exercise in the catalog SHALL have a corresponding image asset
Each exercise entry SHALL reference an `imageAssetName` that maps to an existing `*.imageset` in `Assets.xcassets`. The imageset SHALL contain at least a 1x universal JPEG image.

#### Scenario: Image asset exists for all catalog entries
- **WHEN** the app builds
- **THEN** `SquatGuide`、`LatPulldownGuide`、`BenchPressGuide`、`BarbellRowGuide`、`DeadliftGuide` imagesets all exist in `Assets.xcassets` with valid `Contents.json`
