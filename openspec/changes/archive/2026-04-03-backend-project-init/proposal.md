## Why

Go 后端服务骨架、基础路由、日志和健康检查已经实现，但没有独立的 OpenSpec change 记录。需要补回工程初始化流程，明确这个 change 只覆盖基础服务壳，不覆盖全部业务。

## What Changes

- 为现有 Go 后端项目初始化补齐 OpenSpec 工件
- 记录项目结构、健康检查、日志与中间件基础设施
- 明确项目骨架与业务接口实现的边界

## Capabilities

### New Capabilities
- `backend-project-init`: WinTrain Go 后端服务的工程初始化与基础运行骨架

### Modified Capabilities

（无）

## Impact

- 后端：`backend/cmd/api/main.go`
- 后端：`backend/internal/`
- 后端：健康检查与基础中间件
