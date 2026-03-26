## 1. 系统架构概览文档

- [ ] 1.1 创建 `docs/architecture/system-overview.md`，包含三层组件关系图（iOS / Go 后端 / LLM 服务）
- [ ] 1.2 在 system-overview.md 中说明组件间通信方式（HTTPS）和禁止的直连路径（iOS 不得直调 LLM）
- [ ] 1.3 在 system-overview.md 中记录视频上传路径决策（客户端直传后端，预留对象存储扩展）
- [ ] 1.4 在 system-overview.md 中记录后端部署形态决策（单体 + Docker + VPS）
- [ ] 1.5 在 system-overview.md 中记录视频存储策略决策（分析完即丢弃，端侧优先）

## 2. 模块边界文档

- [ ] 2.1 创建 `docs/architecture/module-boundaries.md`，列出 iOS 客户端的完整职责清单
- [ ] 2.2 在 module-boundaries.md 中列出 Go 后端的完整职责清单
- [ ] 2.3 在 module-boundaries.md 中列出 LLM 服务的职责边界（仅接收关键帧，返回结构化 JSON）
- [ ] 2.4 在 module-boundaries.md 中明确列出各模块的禁止行为（SHALL NOT 清单）
- [ ] 2.5 在 module-boundaries.md 中记录历史记录存储位置决策（iOS 本地，后端不提供历史查询 API）

## 3. 数据流文档

- [ ] 3.1 创建 `docs/architecture/data-flow.md`，描述分析成功完整流程（7 步）
- [ ] 3.2 在 data-flow.md 中描述 low_confidence 流程（不计次，展示重拍引导）
- [ ] 3.3 在 data-flow.md 中描述技术失败流程（不计次，展示重试选项）
- [ ] 3.4 在 data-flow.md 中描述配额状态数据流（App 启动查询 + 分析响应附带 + 5 分钟缓存）
- [ ] 3.5 在 data-flow.md 中描述设备标识数据流（Keychain UUID 生成、携带、恢复场景）

## 4. 文档 Review 与确认

- [ ] 4.1 确认三份文档与 PRD 第 4、10 节（架构边界、隐私原则）无冲突
- [ ] 4.2 确认三份文档与 architecture-open-questions.md 中已决策的 P0 问题一致
- [ ] 4.3 确认 design.md 中的 Open Questions 已正确标注归属 change，不遗漏
- [ ] 4.4 将本 change 的决策摘要更新至 architecture-open-questions.md 对应条目（Q2、Q3、Q10 标记为已决策）
