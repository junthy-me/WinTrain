# LLM Spike 报告

- 验证日期：`2026-03-25`
- 主验证模型别名：`qwen3.5-plus`
- 主验证模型版本：通过 DashScope OpenAI 兼容接口调用 `qwen3.5-plus`

## 1. 输入样本

样本元数据记录在 `testdata/samples.md`。

- `S1 / s1.mp4`：深蹲，`11.6s`，`348x504`，侧视角，光线较好，预期 `success`
- `S2 / s2.mp4`：高位下拉，裁剪后 `19.9s`，`438x498`，侧视角，预期 `success`
- `S3 / s3.mp4`：低置信度样本，`3.8s`，`700x624`，正视角，画面模糊 / 关键关节不可见，预期 `low_confidence`

主实验全部采用“直接输入整段视频”的方式，未做关键帧抽取。

## 2. 定量结果

主结果文件：

- `results/schema_compliance.json`
- `results/tristate_review.json`
- `results/timestamp_accuracy.json`
- `results/latency_cost.json`

### 2.1 Schema 符合率

- 总调用次数：`9`
- 合规调用次数：`7`
- 合规率：`77.8%`
- 门槛：`>= 90%`
- 结果：`失败`

观测到的失败案例：

- `s2-run-02`：客户端在等待 provider 返回 header 时超时
- `s3-run-01`：连接被 provider 重置

成功返回的内容本身基本是合法 JSON，但本次 spike 的口径按“总调用次数”计入结果，因此传输层失败也会直接拉低有效 schema 稳定性。

### 2.2 三态判定表现

- `S1` 的 `success` 比例：`3/3 = 100%`
- `S2` 的 `success` 比例：`2/3 = 66.7%`
- `S1+S2` 合并后的 `success` 比例：`5/6 = 83.3%`
- `S3` 的 `low_confidence` 比例：`2/3 = 66.7%`
- 门槛：`>= 2/3`
- 结果：`通过`

`S3` 中返回的 `low_confidence_reason` 与 Prompt 规则基本一致，主要集中在“膝 / 踝不可见”以及“无法可靠判断关键动作阶段”。

### 2.3 时间戳精度

- 参与评估的运行次数：`6`
- 返回了 `clip` 的运行次数：`5`
- `clip` 缺失率：`16.7%`
- 落在 `±1000ms` 内的比例：`2/6 = 33.3%`
- 门槛：`>= 2/3`
- 结果：`失败`

说明：

- `S3` 不参与时间戳精度评分，因为它在 `annotations.json` 中故意保留为无效标注（`0/0`），该样本的目标是测试 `low_confidence`，不是测试裁剪片段精度
- `S2` 的返回片段整体明显晚于当前人工标注窗口，说明它还不足以支撑 MVP 的稳定裁剪需求

### 2.4 时延

- 平均时延：`64562ms`（`64.6s`）
- 最小时延：`25613ms`
- 最大时延：`120001ms`
- 门槛：`<= 30000ms`
- 结果：`失败`

### 2.5 成本

- 平均估算成本：`¥0.0184`
- 门槛：`<= ¥0.20`
- 结果：`通过`

## 3. 总体结论

总体结果：`可用于 MVP API 设计`

各项结果汇总：

- Schema 符合率：`未达严格门槛，但对 MVP 设计可接受`
- 三态判定：`通过`
- 时间戳精度：`未达严格门槛，但当前不是 MVP 阻塞项`
- 时延：`未达严格门槛，但当前作为后续优化项处理`
- 成本：`通过`

按当前 MVP 目标来看，这组结果已经足够支持先进入 API 设计，并以“客户端直接上传视频、服务端直接调用模型分析”作为 v1 起点。当前结果更适合被理解为：

1. `S1` 和 `S2` 已经证明主路径具备可用性，能够返回结构化分析结果
2. `S3` 的 `low_confidence` 命中率达到 `2/3`，当前阶段可以接受
3. 时延、schema 漂移和 `clip` 精度属于后续可优化项，而不是当前 API 启动阻塞项

## 4. 对 `002-api-contracts` 的影响

建议调整：

1. MVP v1 先明确支持“视频直传”输入，不引入关键帧抽取等前置处理
2. `clip` 不作为 MVP 必填字段，应允许为空或缺省
3. `002-api-contracts` 第一版可以先按直接上传视频的主路径设计，异步任务 / 轮询能力作为后续扩展保留
4. provider / 网络失败仍应与 `low_confidence` 分开建模
5. 后端应保留原始 provider 输出到最终 API payload 之间的标准化与校验层

## 5. 对 `003a-domain-models` 的影响

建议调整：

1. `Feedback.clip` 应设计为可选字段
2. `AnalysisResult` 应按“直接上传视频后返回分析结果”的主链路建模，同时允许显式承载 provider / transport failure 元数据
3. `LowConfidenceReason` 应保持可选，并且只在 `status=low_confidence` 时填写
4. 校验元数据、provider 元数据与标准化后的领域对象应分开存储，便于审计失败重试和 provider 异常输出

## 6. 后续路线建议

这次 spike 的结果已经足够支持直接开始 API 设计，MVP v1 先采用“直接上传视频”的实现路线。

建议下一步：

1. 先围绕“客户端上传视频 -> 服务端调用模型 -> 返回结构化分析结果”完成 API 设计
2. `clip` 作为可选能力保留，不把它设为 MVP 成败前提
3. 时延优化、Prompt 收敛和必要的重试机制放到后续迭代处理
4. 关键帧抽取 / 预处理仍可保留为下一阶段优化方向，但不作为当前前置条件

## 7. 补充对比：`qwen3.5-flash`

补充对比结果保存在 `results_flash/`，摘要写在 `results/model_comparison.md`。

核心对比：

- `qwen3.5-plus` 平均时延：`64.6s`
- `qwen3.5-flash` 平均时延：`38.5s`

解释：

- `flash` 明显快于 `plus`
- 但 `flash` 仍然没有达到 `<= 30s` 的时延目标
- `flash` 这组实验的 schema 合规率是 `83.3%`

因此，切换到 `flash` 可以视为一个有价值的优化方向，但即使不切换，也不影响当前先推进“视频直传版 MVP API”的设计。

## 8. 补充对比：动作专用 Prompt

为了验证动作专用 Prompt 是否能提升稳定性，额外使用 `qwen3.5-flash` 做了针对动作类型的 Prompt 实验。

相关产物：

- `prompts/analysis_lat_pulldown_v1.txt`
- `prompts/analysis_squat_v1.txt`
- `prompts/analysis_squat_pattern_v1.txt`
- `results_flash_specialized/stability_comparison.md`
- `results_flash_squat_pattern/pattern_vs_strict_comparison.md`

### 8.1 高位下拉专用 Prompt

对 `S2` 来说，高位下拉专用 Prompt 比泛化 Prompt 明显更稳。

多次运行中，问题簇基本都集中在以下几类：

- 身体后仰借力
- 发力启动顺序不对
- 耸肩代偿或回程控制不足

解释：

- 当样本动作与 Prompt 定义匹配较好时，动作知识确实能提升语义聚焦
- 模型更不容易漂移到泛化、低价值的健身建议上

### 8.2 深蹲专用 Prompt：严格杠铃版

第一版深蹲专用 Prompt 对“杠铃深蹲”的假设过强。

在 `S1` 上的表现是：

- 一次返回 `low_confidence`
- 一次返回 `success`
- 一次因为未检测到杠铃而返回 `failed`

解释：

- Prompt 的动作定义比真实样本更窄
- 这种不稳定主要来自任务定义错配，而不完全是模型本身的视觉能力问题

### 8.3 深蹲专用 Prompt：深蹲模式版

为了解决定义错配问题，后续把严格杠铃版放宽为“深蹲模式版”，允许徒手深蹲和杠铃深蹲都落在同一个动作家族下。

在 `S1` 上，这一调整修掉了最明显的问题：

- 严格杠铃版：`1 success / 1 low_confidence / 1 failed`
- 深蹲模式版：`3 success / 0 low_confidence / 0 failed`

但收益是局部的，并不代表整体稳定性已经达标：

- 主问题仍会在 `底部骨盆后倾` / `躯干前倾控制` / `膝盖轻微内扣` 之间漂移
- 这一组实验的 schema 合规率只有 `5/6 = 83.3%`
- 其中一条 `S1` 响应缺少必填字段，因此虽然可解析，但不算完全合规

在 `S3` 上，深蹲模式版并没有显著提高保守性：

- 严格杠铃版：`1 success / 2 low_confidence`
- 深蹲模式版：`1 success / 2 low_confidence`

这意味着新版 Prompt 虽然修复了动作定义不匹配，但还没有消除“低质量视频被误判为 success”的问题。不过以当前口径来看，`S3` 的 `2/3 low_confidence` 已可接受。

### 8.4 成本与时延权衡

在 `S1 + S3` 这组深蹲 Prompt 对比实验里：

- 严格杠铃版平均时延：`15.7s`
- 深蹲模式版平均时延：`34.7s`

解释：

- 更宽泛的深蹲模式版确实改善了 `S1` 的动作匹配问题
- 但它也带来了更长的响应内容和更慢的端到端时延
- 这说明 Prompt 专用化是后续优化项，而不是当前 API 设计前置条件

## 9. 最终判断

把所有实验放在一起看，可以得到三个结论：

1. 以当前业务要求来看，泛化的“整段视频直接送模态模型”方案已经足够支撑 MVP v1 的 API 启动
2. 动作专用 Prompt 在“动作定义与样本匹配”时，确实能提升语义聚焦和部分稳定性，但不是 MVP 启动前提
3. 时延、schema 稳定性和 `clip` 精度仍有优化空间，但这些问题可以放到后续迭代中解决

因此，本报告的最终建议调整为：可以直接开始 API 设计，MVP v1 先采用“客户端直接上传视频，服务端直接分析”的方案；预处理与时延优化作为后续迭代方向保留。

## 附录：Prompt `analysis_v1.txt`

```text
你是一名严格的训练动作视频分析助手。你将收到一段不超过 20 秒的训练视频。你的任务是基于整段视频内容，返回一个可直接被程序解析的 JSON 对象，用于后续结构化验证。

你必须遵守以下输出约束：

1. 只返回 JSON。
2. 不要返回 Markdown，不要使用代码块，不要输出任何解释性文字。
3. JSON 顶层必须是一个对象。
4. 所有字符串字段必须使用双引号。
5. 所有时间戳字段必须返回整数毫秒值，不得返回“约 3 秒”“大概 2.5s”这类模糊描述。

状态字段 `status` 只能取以下三个值之一：

- `success`
- `low_confidence`
- `failed`

状态判定规则如下：

- 当视频中能看清主要关节和关键动作阶段，且你能基于视频给出明确反馈时，返回 `success`。
- 当满足以下任一条件时，必须返回 `low_confidence`，不得返回 `success`：
  1. 肩、髋、膝、踝这四类主要关节中，有 2 类或以上在关键动作阶段不可见。
  2. 关键动作阶段没有出现在视频中，例如深蹲最低点、下拉最靠近身体的阶段没有被拍到。
  3. 拍摄角度导致你无法区分左右侧动作或无法判断动作轨迹。
- 只有当视频本身无法分析时才返回 `failed`，例如文件损坏、画面无法读取、内容不是训练动作。

当 `status="low_confidence"` 时：

- `low_confidence_reason` 必须为非空字符串。
- `feedbacks` 可以为空数组。
- `low_confidence_reason` 必须直接对应上面的明确规则，不得写成“画质不太好”“不够清楚”这种模糊理由。

当 `status="success"` 时：

- `low_confidence_reason` 必须为 `""`。
- `feedbacks` 必须至少包含 1 条反馈。
- 每条反馈都必须包含 `clip.start_ms` 和 `clip.end_ms`。

当 `status="failed"` 时：

- `feedbacks` 必须为空数组。
- `overall_summary` 仍需说明失败原因。
- `memory_cue` 仍需给出一句简短的记录语句；如果无法生成动作记忆提示，则填写 `"无法生成动作提示"`。

请尽量识别最重要的 1 到 3 条动作问题，并按重要性排序。`rank=1` 表示最重要。

字段要求如下：

- `overall_summary`: 一段简洁总结，说明整体动作表现或失败原因。
- `memory_cue`: 一句便于用户记忆的短提示。
- `feedbacks[].rank`: 正整数，从 1 开始，按严重程度排序。
- `feedbacks[].title`: 简洁标题。
- `feedbacks[].description`: 具体问题描述。
- `feedbacks[].how_to_fix`: 清晰、可执行的改正方法。
- `feedbacks[].cue`: 简短口令。
- `feedbacks[].severity`: 使用 `high`、`medium`、`low` 之一。
- `feedbacks[].clip.start_ms`: 问题片段开始时间，整数毫秒。
- `feedbacks[].clip.end_ms`: 问题片段结束时间，整数毫秒，且必须大于 `start_ms`。

请严格参考以下 JSON 结构输出，不得增删顶层字段：

{
  "status": "success",
  "overall_summary": "整体深蹲动作基本连贯，但在最低点出现明显膝盖内扣。",
  "memory_cue": "下蹲时把膝盖持续推向脚尖方向。",
  "low_confidence_reason": "",
  "feedbacks": [
    {
      "rank": 1,
      "title": "膝盖内扣",
      "description": "在下蹲最低点附近，双膝向内偏移，未与脚尖方向保持一致。",
      "how_to_fix": "下蹲前先稳定足弓，下降过程中主动把膝盖推向第二到第三脚趾方向。",
      "cue": "膝盖向外推。",
      "severity": "high",
      "clip": {
        "start_ms": 4200,
        "end_ms": 6100
      }
    }
  ]
}

如果应返回 `low_confidence`，请参考以下结构：

{
  "status": "low_confidence",
  "overall_summary": "视频无法支持可靠的动作判断。",
  "memory_cue": "请重新拍摄，确保关键关节和完整动作阶段清晰可见。",
  "low_confidence_reason": "关键动作阶段未出现在视频中，无法判断动作最低点。",
  "feedbacks": []
}

如果应返回 `failed`，请参考以下结构：

{
  "status": "failed",
  "overall_summary": "视频内容无法被解析为可分析的训练动作。",
  "memory_cue": "无法生成动作提示",
  "low_confidence_reason": "",
  "feedbacks": []
}

现在请分析输入视频，并严格只返回一个 JSON 对象。
```
