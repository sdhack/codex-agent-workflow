# 维护说明

当前版本：`V0.1.9`。

每次更新 `SKILL.md`、角色模板、脚本、参考资料或 UI 元数据时，都必须递增版本、更新 `agents/openai.yaml` 的 `display_name`，并在 `CHANGELOG.md` 记录变更。展示名固定为 `GM 分层多代理配置 V版本号`。

提交前验证 Sol/Luna 角色目录、项目级配置路径和最小冒烟流程，且不得覆盖无关用户配置。

`V0.1.9` 文档同步清单：

- `README.md`、`CHANGELOG.md`、本文件
- `references/routing-protocol.md`
- `references/stage-gates.md`
- `references/task-card.md`
- `references/reporting-contract.md`
- `references/cost-quality-metrics.md`
- `references/project-template/AGENTS.md`
- `references/project-template/CLAUDE.md`

上述文件中的 Sol 调度规则必须保持一致：真实运行中的子任务持续等待至终态；独立任务最多并行 3 个并分别设置任务卡和闸门；全部完成且独立验收后统一输出；失败、超时、缺产物或需用户输入时锁定依赖阶段。`SKILL.md` 与 `agents/openai.yaml` 的版本同步由版本发布变更另行维护。

所有文本文件以 UTF-8（无 BOM）保存；Windows 上的 Python 校验必须启用 UTF-8 模式，避免系统默认 GBK 造成误判。
