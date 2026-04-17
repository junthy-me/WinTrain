## Why

当前分析三态在契约层和实现层存在三个关键偏差：

- `status=success` 被错误约束为“必须至少返回 1 条 feedback”，导致模型可能为无明显问题的视频强行编造问题。
- provider 返回缺失或非法 `status` 时，后端与 iOS 的兜底和展示语义不够清晰，容易把结构化异常直接暴露给用户。
- iOS 已开始区分 `low_confidence` 与 `failed` 的展示，但后端 prompt、规范化逻辑与 API 文档尚未完全对齐这套语义。

需要收敛一版更合理的三态契约：`success` 表示“分析成功且可信”，而不是“必须存在问题”；`low_confidence` 承接拍摄/可见性不足；`failed` 承接技术失败或结构化结果不可用。

## What Changes

- 调整分析结果三态契约：
  - `success` 允许 `feedbacks=[]`，表示“未发现需要重点纠正的问题”
  - `low_confidence` 必须带非空 `low_confidence_reason`
  - `failed` 不再承载拍摄指导语义
- 调整 provider 结果标准化规则：
  - 若 `status` 缺失/非法，优先依据 `low_confidence_reason` 和结构完整性做保守补偿
  - 不再因为 `success` 缺少 feedback 就自动降级为 `low_confidence`
- 调整 iOS 结果展示：
  - `low_confidence` 与 `failed` 继续分开展示
  - `success + feedbacks=[]` 视为“动作优秀/无明显问题”
- 更新 API/数据流文档，使成功但无问题的结果、低置信度结果和技术失败结果的字段语义一致。

## Capabilities

### Modified Capabilities

- `analysis-service`: 分析三态契约、provider 结果标准化、prompt 输出要求
- `api-contracts`: analysis response 的字段约束与三态语义
- `result-display`: iOS 结果页对 `success`/`low_confidence`/`failed` 的展示分流
- `data-flow`: 成功但无问题时的返回与本地派生片段行为

## Impact

- `backend/internal/analysis/prompts.go`
- `backend/internal/analysis/service.go`
- `backend/internal/analysis/service_test.go`
- `ios/WinTrain/Views/ResultView.swift`
- `ios/WinTrain/Services/APIClient.swift`
- `docs/contracts/analysis-api.md`
- `openspec/specs/api-contracts/spec.md`
- `openspec/specs/analysis-service/spec.md`
- `openspec/specs/result-display/spec.md`
- `openspec/specs/data-flow/spec.md`
