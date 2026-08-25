# 维护说明

当前版本：`V0.1.3`。

每次更新 `SKILL.md`、角色模板、脚本、参考资料或 UI 元数据时，都必须递增版本、更新 `agents/openai.yaml` 的 `display_name`，并在 `CHANGELOG.md` 记录变更。展示名固定为 `GM 分层多代理配置 V版本号`。

提交前验证 Sol/Luna 角色目录、项目级配置路径和最小冒烟流程，且不得覆盖无关用户配置。

所有文本文件以 UTF-8（无 BOM）保存；Windows 上的 Python 校验必须启用 UTF-8 模式，避免系统默认 GBK 造成误判。
