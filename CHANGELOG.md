# 更新记录

本文件记录 `codex-agent-workflow` 的用户可见配置、脚本和文档变更。

## [0.1.7] - 2026-08-31

### Fixed

- 统一安装命令和仓库链接为 `sdhack/codex-agent-workflow`。
- 澄清官方 ChatGPT 登录与自定义 API Key/Gateway 的双认证路径，并明确 Sol/Luna 的 low 推理强度和 `service_tier = "default"` 标准速度配置。
- 修正 Windows 桌面版验证命令，指向全局技能目录中的实际校验脚本。
- 补充 bootstrap 保留已有文件、Luna V1 catalog 生成及密钥不落盘的边界说明。
- 统一个人配置示例中的 `[agents]` 子代理字段位置，确保 README、SKILL 与项目模板一致。

## [0.1.5] - 2026-08-25

### Changed

- GitHub 仓库地址与项目链接同步为 `sdhack/codex-agent-workflow`。

## [0.1.4] - 2026-08-25

### Fixed

- README 新增当前版本、变更记录和维护文档入口，补齐文档导航。

## [0.1.3] - 2026-08-25

### 已变更

- 强化 README 的阶段闸门、执行边界和可追溯验收说明。

## [0.1.2] - 2026-08-25

### 已变更

- 强制技能文本文件使用 UTF-8（无 BOM），并规定 Windows 校验必须显式启用 UTF-8 模式。

## [0.1.1] - 2026-08-25

### 已变更

- 建立技能维护文档与中文列表展示名。
- 规定后续每次更新必须同步递增展示名中的 `V` 版本号。

## [0.1.0]

### 已新增

- 初始 Sol 指挥、Luna 执行的分层代理配置与验证流程。
