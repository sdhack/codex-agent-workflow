# 🤖 codex-agent-workflow

Sol/Luna 分层代理工作流：Sol 负责目标、架构与最终验收，Luna 负责可验证的探索、实现、测试和审查。

## 📦 安装

```bash
npx skills add sdhack/codex-agent-workflow -g -y
bash ~/.agents/skills/codex-agent-workflow/scripts/bootstrap.sh "$(pwd)"
```

脚手架创建或保留 `.codex/config.toml`、`.codex/agents/`、`.claude/agents/`、`AGENTS.md`、`CLAUDE.md` 和验证脚本。Windows 原生环境使用 PowerShell 路径；WSL 使用 `/mnt/c/...`，不要混用。

## 🔐 认证

### ✅ 官方 Codex/ChatGPT（推荐）

Codex Desktop 选择 **Sign in with ChatGPT**；CLI 使用：

```bash
codex login
codex login status
```

官方模式不需要 API Key、`model_provider` 或第三方 Gateway。

### 🔑 自定义 API Key/Gateway

```bash
cp .codex/config.custom-gateway.toml.example .codex/config.toml
export GATEWAY_API_KEY="<your-key>"
```

端点必须支持 OpenAI-compatible `/v1/responses`。`env_key` 只能写环境变量名；真实密钥不得写入文件、Git、日志或任务消息。直连 OpenAI API 时可使用 `OPENAI_API_KEY` 并同步修改 `env_key`。

## ⚙️ 默认配置

```toml
model = "gpt-5.6-sol"
model_reasoning_effort = "low"
service_tier = "default"

[features]
multi_agent = true
multi_agent_v2 = false

[agents]
default_subagent_model = "gpt-5.6-luna"
default_subagent_reasoning_effort = "low"
```

`low` 为轻度思考，`default` 为标准速度和标准计费。复杂任务可单次提高强度，不改变默认值。

## ✅ 验证

```bash
bash -n scripts/bootstrap.sh
bash -n scripts/prepare-luna-catalog.sh
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/validate-setup.ps1 -Root .
powershell -NoProfile -ExecutionPolicy Bypass -File ./scripts/validate-role-definitions.ps1 -Root .
codex exec --sandbox read-only -c 'model="gpt-5.6-sol"' "Reply with exactly: SOL_SMOKE_OK" </dev/null
codex exec --sandbox read-only -c 'model="gpt-5.6-luna"' "Reply with exactly: LUNA_SMOKE_OK" </dev/null
```

多代理测试必须返回 `SCOUT_DONE`，并确认无越界 diff、错误日志或关键产物缺失。出现 `Unknown model gpt-5.6-luna` 时运行：

```bash
bash scripts/prepare-luna-catalog.sh "$(pwd)/.codex/models-v1.json"
```

再设置 catalog 绝对路径并保持 `multi_agent_v2 = false`。catalog、`.env` 和日志不应提交。

## 🤝 协作与安全

流程为：盘点 → 实现 → 验证 → 审查 → Sol 验收。每个 Luna 任务必须限定目标、文件范围、验收和回报；Luna 不改变架构、不提交、不发布、不处理密钥，Sol 独立检查 diff、测试、日志和产物。阶段失败最多回派两次，证据不足不得放行。

本项目不是操作系统级权限隔离。不要提交 API Key、密码、私钥、主机秘密、`.env`、catalog 或运行日志。实验性注入完成后必须卸载，不得写入开机自启。

## 🛠️ 故障排查

| 现象 | 处理 |
|---|---|
| `Unknown model gpt-5.6-luna` | 生成 V1 catalog，设置绝对路径，关闭 `multi_agent_v2` |
| Codex 不读取规则 | 信任并重新打开项目，确认根目录有 `AGENTS.md` |
| Gateway `/v1/responses` 报错 | 检查端点、`wire_api` 和环境变量名 |
| 验证退出 0 但无产物 | 按失败处理，检查数量、唯一 ID、顺序和日志 |

## 📚 文件与链接

- `SKILL.md`：完整技能协议
- `references/project-template/`：项目模板
- `scripts/bootstrap.sh`：初始化脚本
- `scripts/prepare-luna-catalog.sh`：catalog 脚本
- `scripts/validate-*.ps1`：校验脚本
- [CHANGELOG.md](CHANGELOG.md) · [MAINTENANCE.md](MAINTENANCE.md) · [DISCLAIMER.md](DISCLAIMER.md)

MIT License。项目地址：[github.com/sdhack/codex-agent-workflow](https://github.com/sdhack/codex-agent-workflow)
