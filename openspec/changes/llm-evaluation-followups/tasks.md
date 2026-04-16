## 1. 模型对照

- [ ] 1.1 使用 Gemini 视频输入接口对主样本执行对照分析
- [ ] 1.2 记录 Gemini 的 schema 符合率、延迟、成本，并与当前主模型对比
- [ ] 1.3 将对照结果更新到 `docs/architecture/llm-integration.md`

## 2. 后续优化验证

- [ ] 2.1 评估是否需要关键帧/预处理路线
- [ ] 2.2 重新验证 schema 稳定性与时间戳精度
- [ ] 2.3 重新验证时延与成本表现

## 3. OpenSpec 工件

- [x] 3.1 创建 `llm-evaluation-followups` change proposal
- [x] 3.2 创建 `llm-evaluation-followups` change design
- [x] 3.3 创建 `llm-evaluation-followups` delta spec
- [x] 3.4 创建 tasks
