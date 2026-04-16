## 1. 环境准备与样本收集

- [x] 1.1 创建 `backend/poc/llm-spike/` 目录结构，添加 `README.md` 说明 spike 目的、主验证路径（直接视频输入）与使用方法
- [x] 1.2 在 `backend/.gitignore`（或根 `.gitignore`）中添加 `poc/llm-spike/testdata/` 排除规则，防止视频样本提交至 Git
- [x] 1.3 收集 S1 样本：深蹲视频，时长 ≤ 20 秒，正常角度 + 典型错误；若超过 20 秒则裁剪，记录视频时长、分辨率、主要特征至 `testdata/samples.md`
- [x] 1.4 收集 S2 样本：高位下拉视频，时长 ≤ 20 秒，正常角度 + 典型错误；记录特征至 `testdata/samples.md`
- [x] 1.5 收集 S3 样本：任意动作，时长 ≤ 20 秒，角度不佳或存在遮挡，记录特征至 `testdata/samples.md`
- [x] 1.6 为每段样本视频完成人工标注：标记关键错误片段起止时间（毫秒精度），保存至 `testdata/annotations.json`

## 2. Prompt 编写

- [x] 2.1 编写 P1 Prompt（结构化输出约束）：包含完整 JSON schema 示例，明确要求"只返回 JSON，不返回其他内容"
- [x] 2.2 编写 P2 Prompt（三态判定条件）：以明确判断规则定义 `low_confidence` 触发条件（至少 3 条规则，不得使用模糊表述）
- [x] 2.3 编写 P3 Prompt（时间戳要求）：要求模型返回基于视频时间轴的具体 `clip.start_ms / end_ms` 数值，精确到秒级或亚秒级
- [x] 2.4 将 P1/P2/P3 合并为单一完整 Prompt，保存至 `prompts/analysis_v1.txt`
- [x] 2.5 验证 Prompt 可读性：人工检查是否包含歧义表述，确认 `low_confidence` 触发条件明确

## 3. 直接视频输入调用验证

- [x] 3.1 编写 `backend/poc/llm-spike/cmd/run_analysis/main.go`：读取视频文件，构造 qwen3.5-plus 视频输入请求（确认 base64 vs URL 传入方式）
- [x] 3.2 调用程序 SHALL 记录每次请求的端到端延迟（ms）、输入/输出 token 用量（若 API 返回）、估算成本
- [x] 3.3 对 S1 样本执行 3 次独立调用，原始响应保存至 `testdata/llm_responses/s1/`
- [x] 3.4 对 S2 样本执行 3 次独立调用，原始响应保存至 `testdata/llm_responses/s2/`
- [x] 3.5 对 S3 样本执行 3 次独立调用，原始响应保存至 `testdata/llm_responses/s3/`
- [x] 3.6 将每次调用的延迟与成本数据汇总至 `testdata/llm_responses/call_metrics.json`

## 4. 结构化输出解析验证

- [x] 4.1 编写 `backend/poc/llm-spike/cmd/validate_output/main.go`：读取 `llm_responses/`，对每次响应执行 JSON 解析
- [x] 4.2 校验必填字段完整性（`status`、`overall_summary`、`memory_cue`、`feedbacks[]` 及所有子字段）
- [x] 4.3 校验 `low_confidence` 时 `low_confidence_reason` 字段存在且非空
- [x] 4.4 校验 `clip.start_ms / end_ms` 格式正确性（非负整数，`end_ms > start_ms`）
- [x] 4.5 统计并输出 schema 符合率（可解析且字段完整 / 总调用次数），保存至 `results/schema_compliance.json`

## 5. 三态判定验证

- [x] 5.1 统计 S3 样本中 `status=low_confidence` 的触发次数与总调用次数，计算触发率
- [x] 5.2 统计 S1/S2 样本中 `status=success` 的出现率
- [x] 5.3 记录每次 `low_confidence` 响应中的 `low_confidence_reason`，核查是否与 Prompt 规则对应
- [x] 5.4 将三态判定结果汇总保存至 `results/tristate_review.json`

## 6. 时间戳精度验证

- [x] 6.1 读取 `testdata/annotations.json`（人工标注）和 `llm_responses/` 中的 `clip` 字段
- [x] 6.2 计算每次 `clip.start_ms` 与人工标注起始时间的绝对误差，`clip.end_ms` 同理
- [x] 6.3 统计误差 ≤ 1000ms 的比例，保存至 `results/timestamp_accuracy.json`
- [x] 6.4 若 clip 字段缺失（模型未返回），记录缺失率

## 7. 延迟与成本统计

- [x] 7.1 从 `testdata/llm_responses/call_metrics.json` 读取所有调用的延迟数据
- [x] 7.2 计算平均延迟、最大延迟、最小延迟，与 30 秒阈值对比
- [x] 7.3 计算所有调用的平均估算成本，与 ¥0.20 阈值对比
- [x] 7.4 将汇总结果保存至 `results/latency_cost.json`

## 8. 可选延期项归档

说明：Gemini 对照测试与后续优化验证已拆分到 follow-up change `llm-evaluation-followups`，不再作为当前 spike 的未完成尾项。

- [x] 8.1 将 Gemini 视频输入对照测试转移到 `llm-evaluation-followups`
- [x] 8.2 将 schema / 延迟 / 时间戳的后续优化验证转移到 `llm-evaluation-followups`
- [x] 8.3 在当前 spike 文档中明确后续工作归属

## 9. Spike 报告撰写

- [x] 9.1 创建 `backend/poc/llm-spike/REPORT.md`，填写验证日期和模型名称/版本
- [x] 9.2 填写输入样本描述（基于 `testdata/samples.md`，含每段视频时长）
- [x] 9.3 填写五项验证的定量结果（引用 `results/` 下各 JSON 文件数据）
- [x] 9.4 判定整体通过 / 失败，写明判定依据
- [x] 9.5 若整体失败且建议进入预处理优化路线，明确说明后续步骤（在 `009-analysis-service` 引入关键帧抽取）
- [x] 9.6 若存在局部失败项，为每项填写针对 `002-api-contracts` 的具体调整建议
- [x] 9.7 若存在局部失败项，为每项填写针对 `003a-domain-models` 的具体调整建议
- [x] 9.8 将最终 Prompt（`prompts/analysis_v1.txt`）内容附录至报告末尾，供 `009-analysis-service` 参考
