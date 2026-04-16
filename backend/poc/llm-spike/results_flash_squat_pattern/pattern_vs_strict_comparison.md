# 深蹲 Prompt 对比：严格杠铃版 vs 深蹲模式版

本轮仅比较 `qwen3.5-flash` 在深蹲相关样本上的表现：

- 旧版 prompt：`analysis_squat_v1.txt`
- 新版 prompt：`analysis_squat_pattern_v1.txt`
- 对比样本：`s1`（真实深蹲样本）、`s3`（故意低置信度样本）
- 每个样本各运行 3 次

## 结论

新 prompt 解决了一个明确问题：`s1` 不再因为“没有杠铃”被判成 `failed` 或 `low_confidence`。在这 3 次里，`s1` 全部返回 `success`。

但新 prompt 没有彻底解决稳定性问题：

- `s3` 仍然出现 `success / low_confidence` 混合输出，说明对低质量样本的保守性还不够稳定。
- schema 合规率仍未达标，`6` 次里有 `1` 次缺少 `severity` 和 `clip`。
- 平均时延明显变慢，从严格版的 `15.7s` 上升到模式版的 `34.7s`。

因此，这次修改更准确地说是“修复了动作定义不匹配导致的误判”，而不是“全面提升了稳定性”。

## 逐样本对比

### S1

严格杠铃版：

- `run-01`: `low_confidence`
- `run-02`: `success`，主问题是“躯干前倾过大”
- `run-03`: `failed`，原因是未检测到杠铃

深蹲模式版：

- `run-01`: `success`，主问题是“底部骨盆后倾”
- `run-02`: `success`，主问题是“躯干前倾控制”
- `run-03`: `success`，主问题是“膝盖轻微内扣”

判断：

- 新版显著减少了定义错配。旧版把样本先假定为杠铃深蹲，导致它在动作识别层就分裂。
- 新版虽然 3 次都给出 `success`，但“主问题”仍然在 `骨盆后倾 / 躯干前倾 / 膝内扣` 之间切换，一致性只是比旧版好，没有达到稳定收敛。

### S3

严格杠铃版：

- `run-01`: `low_confidence`
- `run-02`: `success`，主问题是“膝盖内扣”
- `run-03`: `low_confidence`

深蹲模式版：

- `run-01`: `success`，主问题是“脚跟离地”
- `run-02`: `low_confidence`
- `run-03`: `low_confidence`

判断：

- 两版都是 `2/3` 的 `low_confidence`，通过率没有变化。
- 新版没有更保守，仍然会在坏样本上偶尔“自信分析”，只是把误判内容从“膝盖内扣”换成了“脚跟离地 / 躯干前倾”。

## 指标对比

严格杠铃版（仅看 `s1 + s3` 这 6 次）：

- 平均时延：`15.7s`
- `s1` 状态分布：`1 success / 1 low_confidence / 1 failed`
- `s3` 状态分布：`1 success / 2 low_confidence / 0 failed`

深蹲模式版：

- 平均时延：`34.7s`
- schema 合规率：`5/6 = 83.3%`
- `s1` 状态分布：`3 success / 0 low_confidence / 0 failed`
- `s3` 状态分布：`1 success / 2 low_confidence / 0 failed`
- `s1/s2 success_rate` 检查口径下：`1.0`
- `s3 low_confidence_rate`：`0.667`

## 推荐解释

如果目标是“不要因为动作类型定义过窄而误伤徒手深蹲”，新 prompt 是有效的。

如果目标是“让模型在深蹲任务上整体更稳定”，这次调整还不够，主要还差两件事：

- 对低质量样本增加更硬的保守门槛，减少 `s3` 这类视频被误判为 `success`
- 进一步压缩输出自由度，限制主问题集合和时间戳写法，减少 schema 漂移
