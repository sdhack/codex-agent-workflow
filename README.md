# Sol + Luna

![Skill](https://img.shields.io/badge/Skill-V0.1.3-2563eb)
![Focus](https://img.shields.io/badge/Focus-可验收协作-16a34a)

## 把昂贵的判断留给 Sol，把可验证的执行交给 Luna

Sol + Luna 是一套面向 Codex、Claude Code 和可选 Pi 的分层代理协议与项目脚手架。

它解决的不是“如何多开几个 Agent”，而是一个更实际的问题：如何让高能力模型负责目标、架构和风险，让低成本模型稳定完成探索、修改、测试和审查，同时让每个阶段都有可检查的证据。

```text
用户目标
   |
   v
Sol 需求理解 · 架构决策 · 风险控制 · 阶段拆解 · 最终验收
   |
   +--> luna_scout   只读盘点、定位文件、确认边界
   +--> luna_worker  低风险执行、局部实现、批量机械修改
   +--> luna_tester  测试、类型检查、产物核验
   +--> luna_critic  安全、回归和测试缺口审查
```

标准流程：

```text
盘点 -> 实现 -> 验证 -> 审查 -> Sol 独立验收
```

## 让多代理协作有证据，而不是有噪声

这个技能把复杂任务拆成有依赖关系的阶段：每个 Luna 只接收当前阶段的任务卡，完成后停止；Sol 独立查看实际 diff、测试结果与产物，再决定是否解锁下一阶段。这样可以避免多个执行 Agent 同时改同一份文件、把失败静默传递到下游，或用“已经完成”的口头回报替代验收。

它适合有明确交付物的工程任务。它不会替用户授权发布、删除或处理密钥，也不把高风险外部操作下放给执行 Agent。

## 你会得到什么

- 一套可以直接复制到项目里的 Sol/Luna 协作协议。
- Codex 项目级 `.codex/agents`、`AGENTS.md` 和 Claude Code agent 模板。
- Luna V1 model catalog 生成脚本，解决 `Unknown model gpt-5.6-luna`。
- 阶段依赖、任务卡、失败回派和验收闸门。
- Windows 原生 PowerShell 与 WSL 两种安装和验证路径。
- 不把 API Key、密码、私钥或本地运行产物写入仓库的安全约束。

## 适合什么场景

适合把一个复杂任务拆成一条可追踪流水线：

- 先扫描仓库，再改代码，再跑测试，最后做独立审查。
- 把清晰、低风险、无架构判断的小活直接交给 `luna_worker`。
- 把重复性重命名、格式调整、模板生成和批量修改交给便宜执行模型。
- 让 Sol 保留需求理解、架构取舍、权限决策、冲突整合和最终责任。
- 在多个 Agent 之间建立文件范围和阶段顺序，避免互相覆盖。

不适合把它当作操作系统级权限隔离。 `AGENTS.md` 中的角色规则必须配合 Codex sandbox、审批设置和真实测试使用。

## 5 分钟启动

### 1. 安装技能

```bash
npx skills add sdhack/sol-luna-setup -g -y
```

### 2. 初始化当前项目

在 Git 仓库根目录执行：

```bash
bash ~/.agents/skills/sol-luna-setup/scripts/bootstrap.sh "$(pwd)"
```

脚手架会创建或更新：

```text
.codex/config.toml
.codex/agents/luna_{scout,worker,critic,tester}.toml
.claude/agents/luna-{scout,worker,critic}.md
AGENTS.md
CLAUDE.md
scripts/prepare-luna-catalog.sh
```

已有的无关配置会保留，不会盲目覆盖。

### 3. 设置个人默认配置

个人配置放在 `~/.codex/config.toml`，不要提交到项目仓库：

```toml
model = "gpt-5.6-sol"
default_subagent_model = "gpt-5.6-luna"

[features]
multi_agent = true
multi_agent_v2 = false

[model_providers.gateway]
base_url = "https://your-openai-compatible-endpoint/v1"
wire_api = "responses"
env_key = "OPENAI_API_KEY"
```

`env_key` 只写环境变量名。真实密钥只通过环境变量或账号登录注入：

```bash
export OPENAI_API_KEY="your-secret"
```

### 4. 生成 Luna catalog

如果 Codex 无法 spawn Luna：

```bash
bash scripts/prepare-luna-catalog.sh "$(pwd)/.codex/models-v1.json"
```

然后在配置中指向生成文件的绝对路径：

```toml
model_catalog_json = "/absolute/path/to/.codex/models-v1.json"

[features]
multi_agent = true
multi_agent_v2 = false
```

生成的 `.codex/models-v1.json` 默认被 Git 忽略。只有运行时真正成功 spawn Luna，才算配置通过。

## Windows + Codex 桌面版

PowerShell 安装：

```powershell
npx skills add sdhack/sol-luna-setup -g -y
```

技能目录应位于：

```text
$env:USERPROFILE\\.agents\\skills\\sol-luna-setup
```

个人 Codex 配置位于：

```text
$env:USERPROFILE\\.codex\\config.toml
```

项目必须在 Codex 中以可信状态打开，项目级 `AGENTS.md` 和 `.codex\\` 配置才会按预期参与任务。Windows 原生环境使用 PowerShell 和 `C:\\...` 路径；WSL 环境使用 Bash 和 `/mnt/c/...` 路径。不要在同一任务中混用两套环境的 `~/.codex`、项目路径和 CLI。

验证脚本：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\\scripts\\validate-setup.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\\scripts\\validate-role-definitions.ps1
```

## 验证标准

配置文件存在不等于配置成功。至少完成以下检查：

```bash
bash -n scripts/bootstrap.sh
bash -n scripts/prepare-luna-catalog.sh
```

单模型冒烟：

```bash
codex exec --sandbox read-only -c 'model="gpt-5.6-sol"' \
  "Reply with exactly: SOL_SMOKE_OK" </dev/null

codex exec --sandbox read-only -c 'model="gpt-5.6-luna"' \
  "Reply with exactly: LUNA_SMOKE_OK" </dev/null
```

多代理验证：

```text
按 AGENTS.md 先派 luna_scout，只读盘点仓库结构；不要修改文件；回报以 SCOUT_DONE 开头。
```

通过标准是：看到了正确的 Luna 子任务、`SCOUT_DONE`、无越界 diff，且日志没有未收口错误。退出码为 0 但缺少关键产物时，仍然算失败。

## 路由规则

Sol 负责：

- 需求理解和目标定义
- 架构设计与跨模块取舍
- 用户授权、权限和破坏性操作决策
- 阶段解锁、冲突整合和最终验收
- commit、PR 和发布

Luna 默认负责所有低风险、边界清晰、无需架构判断、可以直接执行并验证的工作，包括：

- 简单 CRUD 和局部配置修改
- 格式调整、字段增删改和模板套用
- 重复性重命名、批量机械修改
- 已有方案下的局部实现和定向测试
- 只读探索、独立验证和对抗审查

纯问答、单条只读命令和简单状态查询可以由 Sol 直接处理。任务越复杂，越应该按 `luna_scout -> luna_worker -> luna_tester -> luna_critic -> Sol` 串行推进；没有前一阶段的实际证据，不得解锁下一阶段。

## 安全边界

永远不要把以下内容写入仓库、配置文件、README 或 Git 历史：

- API Key、网关 Key、密码、私钥和个人访问令牌
- 主机 IP、SSH 凭据和内部连接信息
- `.env`、模型 catalog 和本地运行日志

本项目的角色文件负责协作纪律，不替代 sandbox、操作系统权限、审批策略和代码审查。

## 目录结构

```text
SKILL.md                         完整技能协议
roles/*.yaml                     Sol/Luna 中立角色定义
references/project-template/     项目级 Codex/Claude 模板
references/*                     任务卡、闸门、回报和成本协议
scripts/bootstrap.sh             项目初始化脚本
scripts/prepare-luna-catalog.sh  Luna V1 catalog 生成脚本
scripts/validate-setup.ps1       结构与脱敏校验
scripts/validate-role-definitions.ps1
```

## 常见问题

| 问题 | 处理 |
|---|---|
| `Unknown model gpt-5.6-luna` | 生成 V1 catalog，设置 `model_catalog_json` 绝对路径，并保持 `multi_agent_v2 = false` |
| Codex 不读取项目规则 | 确认项目可信、`AGENTS.md` 位于项目根目录，并重新打开任务 |
| `codex` 不是命令 | 安装 Codex CLI，或确认桌面版与 CLI 使用的是同一运行环境 |
| `wire_api` 或 `/v1/responses` 报错 | 确认网关确实支持 Responses API，不要把 Chat Completions 端点伪装成 Responses |
| Luna 修改范围外文件 | 停止后续阶段，检查任务卡、sandbox、审批和实际 diff |
| 配置修改后行为不变 | 重启任务，并检查更近目录中的 `AGENTS.override.md` 或 `.codex/config.toml` |

## 设计原则

1. 高能力模型做判断，低成本模型做执行。
2. 每个阶段都有明确输入、输出和完成条件。
3. 证据不足时不解锁下一阶段。
4. 并行只用于依赖独立且写入范围不重叠的工作。
5. 降低 token 成本不能降低测试标准和最终质量。

## 参考

- [OpenAI Codex 配置文档](https://learn.chatgpt.com/docs/config-file/config-basic)
- [OpenAI Codex 子代理文档](https://learn.chatgpt.com/docs/agent-configuration/subagents)
- [AGENTS.md 配置文档](https://learn.chatgpt.com/docs/agent-configuration/agents-md)
- [Anthropic: Building effective agents](https://www.anthropic.com/research/building-effective-agents)
- [项目仓库](https://github.com/sdhack/sol-luna-setup)

## License

MIT
