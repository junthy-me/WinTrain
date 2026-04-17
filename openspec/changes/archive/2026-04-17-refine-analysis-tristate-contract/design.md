## Context

当前系统已经在展示层把 `low_confidence` 与 `failed` 分开，但后端与 prompt 仍保留“`success` 必须包含 feedbacks”的旧假设。这会导致：

- 动作本身良好时，模型被 schema 逼迫输出问题
- provider 结果一旦缺少 `status`，补偿逻辑可能与真实结果语义脱节
- API 和 iOS 的“成功 / 重拍 / 技术失败”三态边界不够稳定

本次变更的目标是把“分析是否可信”和“是否发现问题”分离开。

## Goals / Non-Goals

**Goals**

- 将 `success` 重新定义为“分析成功且可信”，允许 `feedbacks=[]`
- 保持 `low_confidence` 作为拍摄/可见性不足的专用状态
- 保持 `failed` 作为技术失败/结构化结果不可用的专用状态
- 让后端标准化逻辑和 iOS 展示逻辑都基于这套统一契约

**Non-Goals**

- 不修改配额语义：仍然只有 `success` 扣减配额
- 不把 `failed` 改成 2xx 响应
- 不新增新的结果状态枚举

## Decisions

### 1. `success` 允许无 feedback

**选择**：`status=success` 时 `feedbacks` 可以为空数组。

**理由**：`success` 表示“结果可信”，不是“必须发现问题”。空 feedbacks 是“未发现需要重点纠正的问题”的合法表达。

**影响**：

- 后端不再把 `success + feedbacks=[]` 自动改写成 `low_confidence`
- iOS 成功页需把“空 feedbacks”解释为优秀/继续保持

### 2. 缺失/非法 `status` 的补偿采用保守映射

**选择**：

1. 若 `low_confidence_reason` 非空，补偿为 `low_confidence`
2. 否则若 `overall_summary` 非空、`feedbacks` 为合法数组且 `low_confidence_reason` 为空，补偿为 `success`
3. 其余情况补偿为 `failed`

**理由**：不能因为缺少 `status` 就直接信任为成功；但如果结果主体完整，也不应一律降成 `low_confidence`。

### 3. 成功但无问题时不生成问题片段

**选择**：`success + feedbacks=[]` 时不导出本地代表性片段。

**理由**：没有首要问题时，问题片段不存在；继续强制导出会制造无意义媒体文件。

### 4. `low_confidence` 和 `failed` 的用户态分工

**选择**：

- `low_confidence`: 展示重拍引导和动作拍摄要点
- `failed`: 展示技术失败语义，不展示拍摄要点

**理由**：只有 `low_confidence` 才是“视频可识别但不满足拍摄要求”的场景。

## Risks / Trade-offs

- **[风险] success 为空 feedbacks 可能被误认为“漏分析”**
  - 缓解：要求 `overall_summary` 必填，并在 iOS 成功态中把空 feedbacks 渲染为“动作优秀/继续保持”

- **[风险] 状态补偿仍可能误判**
  - 缓解：仅在主体字段足够完整时才补 `success`，否则保守落到 `failed`

- **[风险] POC prompt/validator 与生产契约不一致**
  - 缓解：本次同步更新运行中 prompt；POC 工具可后续跟进，不阻塞主链路
