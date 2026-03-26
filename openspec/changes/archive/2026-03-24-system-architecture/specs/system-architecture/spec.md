## ADDED Requirements

### Requirement: 系统由三个独立组件构成
系统 SHALL 由 iOS 客户端、Go 后端服务、LLM Vision 服务三个组件构成，组件间通过 HTTPS 通信。iOS 客户端不得直接调用 LLM 服务。

#### Scenario: 客户端发起分析请求
- **WHEN** iOS 客户端提交视频进行分析
- **THEN** 请求 SHALL 发送至 Go 后端，由后端负责调用 LLM 服务，客户端不直接与 LLM 通信

---

### Requirement: 视频上传采用客户端直传后端方式
iOS 客户端 SHALL 通过 `multipart/form-data` 将视频直接 POST 到 Go 后端 API。后端 SHALL 在内部将"接收视频"与"分析视频"解耦为两个步骤，以便未来切换为对象存储方案。

#### Scenario: 正常视频上传
- **WHEN** iOS 客户端发起视频上传
- **THEN** 视频 SHALL 通过单次 HTTP POST 请求传输至后端，无需经过第三方对象存储

#### Scenario: 超大文件被拒绝
- **WHEN** 上传的视频文件超过后端设定的大小上限
- **THEN** 后端 SHALL 返回 413 错误，客户端 SHALL 展示提示并引导用户重新录制

---

### Requirement: 后端以单体服务形式部署
Go 后端 SHALL 以单体服务形式运行，使用 Docker 容器化，部署在单台 VPS 上。服务 SHALL 提供 `/health` 健康检查接口。

#### Scenario: 服务健康检查
- **WHEN** 任意客户端或监控系统请求 `GET /health`
- **THEN** 服务 SHALL 返回 200 状态码及服务状态信息

---

### Requirement: 视频分析完成后后端不持久化视频
后端 SHALL 在分析完成后立即清理视频数据，不将视频写入任何长期存储。视频仅在分析过程中存在于内存或临时目录中。

#### Scenario: 分析完成后视频清理
- **WHEN** 动作分析流程完成（无论成功或失败）
- **THEN** 后端 SHALL 清理该次分析使用的视频临时文件，不保留任何视频副本

#### Scenario: 分析过程中服务崩溃
- **WHEN** 后端在分析过程中发生异常退出
- **THEN** 服务重启后 SHALL 清理残留的临时视频文件
