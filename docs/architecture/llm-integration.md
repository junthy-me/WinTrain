# WinTrain LLM 集成方案

## 1. 当前结论

`llm-spike` 已验证结构化输出、三态判定、时间戳、延迟和成本的可行边界。当前工程实现采用以下策略：

- 主链路：后端抽关键帧 + Vision LLM
- 可选补充：直接视频模型作为后续优化/对照，不阻塞主流程
- `Gemini` 对照：标记为可选延期项

## 2. 主链路设计

### 2.1 输入

- `exercise_id`: `squat` / `lat-pulldown`
- 原始视频：`multipart/form-data`
- `install_id`: 请求头传递

### 2.2 关键帧抽取

- 默认抽取 `10` 帧
- 策略：按总时长均匀采样
- 输出分辨率：默认长边不超过 `1280`
- 每帧记录 `timestamp_ms`

后续如果均匀采样不足，再演进为：

- 动作阶段感知抽帧
- 错误峰值帧增采样

## 3. Prompt 结构

Prompt 由三层组成：

1. 通用结构约束
2. 动作专用知识块
3. 输出 schema 示例

输出必须遵守：

- 只返回 JSON
- 顶层对象
- `status` 只能为 `success | low_confidence | failed`
- `feedbacks[].severity` 只能为 `major | minor | info`
- `clip.start_ms/end_ms` 必须是整数毫秒

## 4. 标准化层

Provider 原始输出不会直接透传给客户端。后端需要做二次标准化：

- 提取 JSON 对象
- 校验必填字段
- 标准化 `severity`
- 对缺失/非法字段降级为 `low_confidence` 或 `failed`
- 追加 provider 元数据和 trace id 到日志

## 5. 三态判定规则

### success

- 关键动作阶段可见
- 关节可判断
- 结构化字段齐全

### low_confidence

- 关节缺失、遮挡、角度不佳
- 关键阶段未拍到
- provider 返回可解析但结构不完整
- 模型能判断“无法可靠分析”，但请求本身成功

### failed

- 请求超时
- 上传校验失败
- 抽帧失败
- provider 不可达
- provider 返回无法解析且无法安全降级

## 6. 超时与重试

- 后端总预算：`75s`
- 单次 provider 调用预算：`45s`
- 关键帧抽取预算：`10s`
- provider 仅对网络抖动类错误重试一次
- 任何 `low_confidence` 或 `failed` 都不计次

## 7. 成本与延迟目标

- 单次分析目标：`< 60s`
- 配额扣减前提：结构化校验通过且 `status=success`
- 单次分析成本控制：优先通过控制帧数和图像尺寸完成

## 8. 当前已知风险

- 关键帧均匀采样可能错过最强错误瞬间
- 同步模式下弱网与慢 provider 会拉长首屏等待
- `clip` 依赖 LLM 对时间轴理解，仍需标准化层兜底

## 9. 后续优化路线

- 追加 `Gemini` 直接视频对照
- 对比多 provider 的 JSON 稳定性
- 引入动作阶段感知抽帧
- 视结果决定是否转异步任务
