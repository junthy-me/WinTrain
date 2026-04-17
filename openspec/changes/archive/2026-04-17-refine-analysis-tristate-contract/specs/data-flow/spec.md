## MODIFIED Requirements

### Requirement: 核心分析数据流
系统 SHALL 支持以下完整数据流：iOS 录制视频 → 上传至后端 → 后端抽取关键帧 → 调用 LLM → 解析结构化结果 → 返回 iOS → iOS 展示结果并保存本地历史。

#### Scenario: 分析成功且存在明确问题
- **WHEN** 后端返回 `status: success` 且 `feedbacks` 非空
- **THEN** iOS SHALL 展示成功结果页，并可根据首要反馈的 `clip` 导出本地代表性片段

#### Scenario: 分析成功但未发现明显问题
- **WHEN** 后端返回 `status: success` 且 `feedbacks` 为空数组
- **THEN** iOS SHALL 展示优秀/继续保持结果页，SHALL 将本次结果写入本地历史，且 SHALL NOT 强制导出代表性问题片段

#### Scenario: 分析结果为 low_confidence
- **WHEN** 后端返回 `status: low_confidence`
- **THEN** iOS SHALL 展示重拍引导页和该动作的拍摄要点，SHALL NOT 将本次结果写入历史记录

#### Scenario: 分析结果为 failed
- **WHEN** 后端返回 `status: failed`
- **THEN** iOS SHALL 展示错误提示和重试选项，SHALL NOT 将本次结果写入历史记录
