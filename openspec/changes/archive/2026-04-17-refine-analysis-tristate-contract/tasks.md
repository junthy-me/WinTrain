## 1. Change Scaffold

- [x] 1.1 创建 `refine-analysis-tristate-contract` change proposal / design / tasks
- [x] 1.2 添加 analysis-service / api-contracts / result-display / data-flow delta specs

## 2. Backend Contract Alignment

- [x] 2.1 调整 prompt 模版，允许 `status=success` 时 `feedbacks=[]`
- [x] 2.2 调整 provider 结果标准化逻辑，移除“success 无 feedback 自动降级 low_confidence”
- [x] 2.3 为缺失/非法 `status` 增加新的补偿映射规则
- [x] 2.4 更新 analysis 相关单元测试

## 3. iOS Result Semantics

- [x] 3.1 确认 `low_confidence` 与 `failed` 的结构化响应路径继续可用
- [x] 3.2 调整结果页：`success + feedbacks=[]` 进入“优秀/继续保持”语义
- [x] 3.3 调整结果页：`low_confidence` 继续展示拍摄要点；`failed` 不展示拍摄要点

## 4. Documentation

- [x] 4.1 更新 `docs/contracts/analysis-api.md`
- [x] 4.2 更新 openspec 主 specs

## 5. Verification

- [x] 5.1 `go test ./internal/analysis`
- [x] 5.2 iOS 编译级检查相关文件无新增 Swift 错误
