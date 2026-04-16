## Context

该 change 对应 `recommended-first-changes.md` 中的 `007-backend-project-init`。当前 Go 工程已可构建、可测试，并具备基本 HTTP 运行壳。

## Goals / Non-Goals

**Goals**
- 固化后端工程初始化范围
- 记录服务入口、目录结构和基础中间件能力

**Non-Goals**
- 不在本 change 中覆盖全部业务实现
- 不以此替代上传、分析、配额、订阅等后续 change

## Decisions

### D1. 使用单体 Go HTTP 服务

服务采用单体结构，以 `cmd/api` 为入口，`internal/` 承载业务模块。

### D2. 健康检查和错误处理先落地

在业务接口前先建立 `/health`、日志和错误处理中间件，确保后续调试和部署基础稳定。

## Risks / Trade-offs

- MVP 阶段单体结构简单高效，但后续复杂度上升时仍可拆分

## Open Questions

- 后续 Docker 与生产部署细节还可继续细化
