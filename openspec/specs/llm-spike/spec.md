# Spec: llm-spike

## Purpose

定义 WinTrain 的 LLM 视频分析 spike 范围、验证标准、结果记录方式，以及该 spike 对后续 API 与领域模型设计的支撑边界。

## Requirements

### Requirement: LLM Spike 验证范围与边界

本 spike 的所有验证代码 SHALL 放在 `backend/poc/llm-spike/` 目录下。验证代码 SHALL NOT 创建正式 API 端点、正式数据库模型或正式服务层。验证代码 SHALL NOT 被合并至生产主链路（`internal/`、`cmd/` 目录）。

验证代码的唯一目的是为 `002-api-contracts` 和 `003a-domain-models` 提供数据支撑，不承担任何生产职责。

本轮 spike 的主验证路径为直接视频输入模型分析（≤ 20 秒视频）。关键帧抽取与 rep 分割仅作为后续优化路线保留，不作为本轮核心任务。

#### Scenario: 验证代码隔离

- **WHEN** 开发者在 `backend/poc/llm-spike/` 下编写验证脚本
- **THEN** 该代码 SHALL 作为独立的可执行程序运行（`go run` 或编译为独立二进制），不作为 Go package 被生产代码导入

### Requirement: 输入视频限制

Spike 验证 SHALL 仅使用时长 ≤ 20 秒的视频作为输入样本。若原始样本超过 20 秒，SHALL 先裁剪至 20 秒以内再参与验证。Spike 结论 SHALL 仅对 ≤ 20 秒视频有效，不外推至更长视频场景。

#### Scenario: 超长样本预处理

- **WHEN** 收集到的样本视频时长超过 20 秒
- **THEN** 验证执行者 SHALL 使用视频编辑工具将其裁剪至 ≤ 20 秒，并在 `testdata/samples.md` 中记录裁剪操作

### Requirement: 输入样本方案

Spike 验证 SHALL 使用至少 3 段真实训练视频作为输入样本，覆盖以下三个场景分类：

- **S1（success 路径）**：深蹲视频，正常拍摄角度，光线良好，含可见的典型错误（如膝盖内扣、脚跟离地等），时长 ≤ 20 秒
- **S2（success 路径）**：高位下拉视频，正常拍摄角度，含可见的典型错误（如发力顺序不对、上体晃动等），时长 ≤ 20 秒
- **S3（low_confidence 路径）**：任意动作，拍摄角度不佳或存在明显遮挡或光线不足，使关键关节不可见，时长 ≤ 20 秒

样本视频 SHALL 存放于 `backend/poc/llm-spike/testdata/` 目录，并 SHALL 在 `.gitignore` 中排除，不提交至代码仓库。Spike 文档中 SHALL 描述每段样本视频的基本特征（时长、角度、主要特征），不包含视频本身。

#### Scenario: 样本多样性覆盖

- **WHEN** 执行 spike 验证
- **THEN** 所使用的样本 SHALL 同时覆盖"正常画质含错误"（S1/S2）和"画质不佳"（S3）两类场景，以验证三态判定的边界行为

### Requirement: 直接视频输入调用验证

Spike 主路径 SHALL 将完整视频（≤ 20 秒）直接发送给 qwen3.5-plus 模型，不进行预处理抽帧。

每个样本 SHALL 执行至少 3 次独立模型调用，记录每次调用的原始响应，用于评估输出稳定性。

验证程序 SHALL 记录每次调用的以下指标：
- 端到端延迟（从发送请求到收到完整响应，毫秒精度）
- 输入 token 用量（若 API 返回）
- 输出 token 用量（若 API 返回）
- 估算单次成本（基于模型定价）

验证程序 SHALL 尝试对每次响应进行 JSON 解析，并校验以下必填字段是否存在：

- `status`（值为 `success` / `low_confidence` / `failed` 之一）
- `overall_summary`（非空字符串）
- `feedbacks`（数组，status=success 时至少 1 条）
- `feedbacks[].rank`、`feedbacks[].title`、`feedbacks[].description`、`feedbacks[].how_to_fix`、`feedbacks[].cue`、`feedbacks[].severity`

当 `status=low_confidence` 时，`low_confidence_reason` SHALL 存在且非空。
当 `memory_cue` 存在时，SHALL 为非空字符串。
当 `feedbacks` 中包含 `clip` 字段时，`clip.start_ms` 和 `clip.end_ms` SHALL 均为非负整数，且 `end_ms > start_ms`。

#### Scenario: schema 符合率计算

- **WHEN** 所有样本的模型调用完成
- **THEN** 验证程序 SHALL 输出 schema 符合率（可直接 JSON 解析且必填字段完整的调用次数 / 总调用次数），保存至 `results/schema_compliance.json`

#### Scenario: schema 符合率通过判定

- **WHEN** 计算 schema 符合率
- **THEN** 若符合率 ≥ 90%，本验证项 SHALL 标记为通过；否则标记为失败，并在报告中记录典型失败案例

### Requirement: Prompt 验证范围

Spike SHALL 验证三类核心 Prompt 能力，合并为单一完整 Prompt 发送：

**P1 - 结构化输出 Prompt**：在不使用服务商特定 Structured Outputs API 的情况下，通过 Prompt 约束模型返回符合预定义 schema 的 JSON。Prompt 中 SHALL 包含完整的 JSON schema 示例，并明确要求模型"只返回 JSON，不返回其他内容"。

**P2 - 三态判定 Prompt**：在 Prompt 中明确定义 `low_confidence` 的触发条件，至少包含以下判断依据：
- 主要关节（肩、髋、膝、踝）中有 2 个或以上不在画面内
- 关键动作阶段（如深蹲最低点）未出现在视频中
- 拍摄角度导致无法区分左右侧动作

Prompt 中 `low_confidence` 的触发条件 SHALL 以明确的判断规则描述，不得使用模糊表述（如"画面质量不够好"）。

**P3 - 时间戳 Prompt**：要求模型在 `clip.start_ms / end_ms` 中给出基于视频时间轴的具体时间戳，精确到秒级或亚秒级，不得返回模糊描述。

#### Scenario: P2 三态判定触发

- **WHEN** 对 S3 样本（画质不佳）执行模型调用
- **THEN** ≥ 2/3 的调用 SHALL 返回 `status=low_confidence`，触发理由 SHALL 与 Prompt 中定义的判断条件对应

#### Scenario: P3 时间戳格式

- **WHEN** 对 S1/S2 样本执行模型调用并返回 `clip` 字段
- **THEN** `clip.start_ms` 和 `clip.end_ms` SHALL 为具体数值（非空、非零、非占位符），且 `end_ms > start_ms`

### Requirement: 时间戳精度验证

Spike SHALL 对返回的 `clip.start_ms / end_ms` 进行精度评估。人工核查者 SHALL 在观看样本视频后，记录判断的"关键错误片段"起止时间（毫秒），作为基准标注，保存至 `testdata/annotations.json`。

精度验证 SHALL 计算模型返回时间戳与人工标注的误差（绝对值）。误差 ≤ 1000ms（1 秒）视为可接受精度。

#### Scenario: 时间戳精度通过判定

- **WHEN** 对比模型返回时间戳与人工标注
- **THEN** 若 ≥ 2/3 的 `clip` 时间戳误差在 ±1s 以内，本验证项 SHALL 标记为通过；否则标记为失败，并在报告中记录误差分布

### Requirement: 延迟与成本验证

Spike SHALL 测量并记录每次调用的端到端延迟和估算成本，评估直接视频输入方案在 MVP 同步请求场景下的可行性。

- **延迟通过标准**：主模型平均端到端延迟 ≤ 30 秒
- **成本通过标准**：单次分析估算成本 ≤ ¥0.20

#### Scenario: 延迟统计

- **WHEN** 所有样本调用完成
- **THEN** 验证程序 SHALL 输出每次调用的延迟，以及所有调用的平均延迟、最大延迟，保存至 `results/latency_cost.json`

#### Scenario: 延迟通过判定

- **WHEN** 计算平均延迟
- **THEN** 若平均延迟 ≤ 30 秒，本验证项 SHALL 标记为通过；否则标记为失败，并在报告中记录对 002-api-contracts 接口模式的影响

### Requirement: 成功判定标准

Spike 整体 SHALL 以以下五项验证均通过作为成功条件：

| 验证项 | 通过标准 |
|--------|----------|
| Schema 符合率 | ≥ 90% 的调用可直接 JSON 解析，所有必填字段存在 |
| 三态判定 | `low_confidence` 在 S3 样本中 ≥ 2/3 被正确触发；`success` 在 S1/S2 中 ≥ 2/3 被正确触发 |
| 时间戳精度 | ≥ 2/3 的 `clip` 时间戳与人工标注误差 ≤ 1s |
| 延迟 | 主模型平均端到端延迟 ≤ 30 秒 |
| 成本 | 单次分析估算成本 ≤ ¥0.20 |

任意一项未通过，spike SHALL 标记为整体失败，并在报告中输出该项的失败调整建议。

#### Scenario: Spike 整体通过

- **WHEN** 五项验证均通过
- **THEN** spike 报告 SHALL 标记结论为"直接视频输入方案可行，建议按当前设计推进 002-api-contracts"

#### Scenario: Spike 整体失败，需进入预处理优化路线

- **WHEN** 一项或多项验证未通过，且失败原因与视频输入方式本身相关（如延迟超标、成本超标、时间戳精度不足）
- **THEN** spike 报告 SHALL 明确标记"建议进入预处理优化路线"，并说明应在 `009-analysis-service` 中引入关键帧抽取或 rep 分割预处理

#### Scenario: Spike 部分失败，可局部调整

- **WHEN** 仅 schema 符合率或三态判定未通过
- **THEN** spike 报告 SHALL 明确列出每个失败项及其对 002-api-contracts 或 003a-domain-models 的影响与调整建议，不强制进入预处理路线

### Requirement: Spike 结论报告

Spike 完成后 SHALL 在 `backend/poc/llm-spike/REPORT.md` 中输出验证结论报告，包含以下内容：

- 验证日期、使用的模型名称与版本
- 输入样本描述（每段视频的特征摘要，含时长）
- 每项验证的定量结果（符合率、误差分布、延迟统计、成本估算）
- 整体通过 / 失败判定
- 失败项的调整建议（若有），分别针对 `002-api-contracts` 和 `003a-domain-models`
- 若整体失败且建议进入预处理路线，SHALL 说明预处理路线的具体后续步骤
- Prompt 最终版本（供 `009-analysis-service` 实现时参考）

报告 SHALL 由执行 spike 的工程师手工填写，不由验证程序自动生成。验证程序 SHALL 输出结构化的原始数据（JSON 格式），供报告撰写时引用。

#### Scenario: 报告包含预处理路线建议

- **WHEN** spike 报告标记为整体失败且建议进入预处理优化路线
- **THEN** 报告 SHALL 明确说明：在 `009-analysis-service` 中引入关键帧抽取（均匀采样为初始策略），并评估是否需要额外 spike 验证抽帧方案

#### Scenario: 报告包含局部调整建议

- **WHEN** spike 报告中存在局部失败项（非整体失败）
- **THEN** 报告 SHALL 为每个失败项提供至少一条针对 `002-api-contracts` 或 `003a-domain-models` 的具体调整建议，而非仅描述失败现象
