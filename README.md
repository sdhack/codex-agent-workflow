# Sol + Luna Setup

让高能力模型负责判断，让低成本模型负责执行，让每一步都有证据可验收。

Sol + Luna Setup 是一套面向 Codex、Claude Code 和可选 Pi 的分层代理工作协议与项目脚手架。它解决的不是“多开几个 Agent”，而是如何在不牺牲质量的前提下，把探索、实施、测试和审查稳定地交给 Luna，同时保留 Sol 的架构判断和最终责任。

## 核心架构

```text
Sol
  需求理解 · 架构决策 · 阶段拆解 · 风险控制 · 最终验收
        |
        +-- luna_scout   只读探索、依赖盘点、范围确认
        +-- luna_worker  受限实现、批量修改、模板生成
        +-- luna_tester  测试、类型检查、产物核验
        +-- luna_critic  安全、回归和测试缺口审查
```

标准执行链：

```text
盘点 -> 实现 -> 验证 -> 审查 -> Sol 独立验收
```

## 为什么值得用

- 默认把可限定、可执行、可测试的工作交给 Luna，减少 Sol 重复读文件和写样板代码。
- 用阶段闸门阻止“测试没过但任务已完成”的假成功。
- 用最小上下文传递降低重复 token 消耗。
- 用文件所有权约束并行，避免多个 Agent 修改同一文件。
- 用失败证据和最多两次回派收口重试，避免死循环。
- 不把 API Key、密码、私钥或本地凭据写入项目。
- 同一套角色定义可扩展到 Codex、Claude Code 和其他 Agent 工具。

## 快速开始

### 安装技能

```bash
npx skills add sdhack/sol-luna-setup -g -y
```

### 初始化项目

```bash
bash ~/.agents/skills/sol-luna-setup/scripts/bootstrap.sh "$(pwd)"
```

脚手架会创建项目级：

- `.codex/config.toml`
- `.codex/agents/luna_*.toml`
- `.claude/agents/luna-*.md`
- `AGENTS.md`
- `CLAUDE.md`
- `scripts/prepare-luna-catalog.sh`

已有文件默认保留，不盲目覆盖。

## Codex 桌面版配方（Windows）

Codex 桌面版与 CLI/IDE 共用配置层。最稳妥的配方是：把个人默认放在 `%USERPROFILE%\.codex\config.toml`，把团队协作规则放在项目根目录的 `AGENTS.md`，把项目级 Agent 配置放在项目的 `.codex\agents\`。

### 1. 打开项目

在 Codex 桌面版中打开已经初始化的项目目录。项目最好是 Git 仓库根目录，并确认项目被标记为可信；不受信任的项目可能跳过项目级 `.codex\` 配置、hooks 和规则。

### 2. 安装技能

PowerShell：

```powershell
npx skills add sdhack/sol-luna-setup -g -y
```

若使用本仓库的本地版本，确保技能目录位于：

```text
$env:USERPROFILE\.agents\skills\sol-luna-setup
```

### 3. 写入个人默认配置

在 Codex 桌面版打开设置，选择 `Codex Settings > Open config.toml`，或直接编辑：

```text
$env:USERPROFILE\.codex\config.toml
```

只写模型名、端点和环境变量名，不写真实密钥。示例：

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

### 4. 写入项目配置

在项目根执行：

```powershell
bash ./scripts/bootstrap.sh "$(Get-Location)"
```

如果 Windows 环境没有 Bash，可在 WSL 中执行脚手架，并使用 WSL 项目路径打开仓库。脚手架会保留已有配置，不覆盖无关文件。

桌面版启动新任务后，Codex 会自动读取项目根及当前目录链上的 `AGENTS.md`。本仓库模板会要求 Sol 把边界清晰的探索、实现、测试和审查工作交给 Luna，并要求 Sol 对实际 diff 和测试证据做最终验收。

### 5. 修复 Luna 无法 spawn

如果桌面版报：

```text
Unknown model `gpt-5.6-luna` for spawn_agent
```

在项目根执行：

```powershell
bash ./scripts/prepare-luna-catalog.sh "$(Join-Path (Get-Location) '.codex/models-v1.json')"
```

然后确认项目 `.codex\config.toml` 使用生成 catalog 的绝对路径，并保持：

```toml
model_catalog_json = "C:/absolute/path/to/project/.codex/models-v1.json"

[features]
multi_agent = true
multi_agent_v2 = false
```

不要把 `.codex\models-v1.json` 提交到 Git；它已被 `.gitignore` 排除。catalog 生成失败时不得把 Luna spawn 当作已验证。

### 6. Windows 本地验证

在项目目录运行：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\validate-setup.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\validate-role-definitions.ps1
```

然后在 Codex 桌面版新任务中使用一个只读请求验证委派：

```text
按 AGENTS.md 先派 luna_scout，只读盘点仓库结构；不要修改文件；回报以 SCOUT_DONE 开头。
```

只有同时看到 Luna 子任务、`SCOUT_DONE`、无越界 diff 和无错误日志，才算多代理配置通过。单纯看到配置文件存在不算验证成功。

### 7. 重要边界

- `AGENTS.md` 是行为协议，不是操作系统权限隔离。
- `read-only`、`workspace-write` 等角色边界必须结合 Codex sandbox 和审批设置验证。
- 桌面版当前版本通常已默认启用子代理；显式配置 `multi_agent` 是为了兼容和排查，不代表所有网关都支持 Luna。
- 子代理会增加总 token 和延迟；只有任务可拆解且有独立验收时才值得委派。

官方参考：[Config basics](https://learn.chatgpt.com/docs/config-file/config-basic)、[Subagents](https://learn.chatgpt.com/docs/agent-configuration/subagents)、[AGENTS.md](https://learn.chatgpt.com/docs/agent-configuration/agents-md)、[Windows desktop app](https://learn.chatgpt.com/docs/windows/windows-app)。

### 完整安装顺序

1. 从官方 Windows 桌面版入口安装并启动 ChatGPT/Codex 应用，登录拥有 Codex 权限的账号，并重启一次应用完成更新。
2. 安装 Git、Node.js 20+ 和 npm。Git Bash 适合直接运行本仓库的 `.sh` 脚本；原生 PowerShell 适合运行 `.ps1` 校验脚本。
3. 在 PowerShell 中检查环境：

   ```powershell
   git --version
   node --version
   npm --version
   codex --version
   ```

4. 设置网关所需的环境变量。当前 PowerShell 会话临时设置：

   ```powershell
   $env:OPENAI_API_KEY = "在本机安全注入的值"
   ```

   不要把这条命令写进 README、`config.toml`、Git 历史或任务回报。若使用账号登录而不是 API 网关，则按账号可用模型配置，不要凭空添加不存在的模型名。
5. 在 Codex 桌面版添加或打开项目，确认项目根目录正确，并在受信任状态下运行项目级配置。
6. 安装技能并运行 bootstrap；bootstrap 只负责项目文件，不负责安装桌面应用、创建账号或生成密钥。
7. 关闭并重新打开项目任务，再执行单模型和多代理验证。

### 原生 Windows 与 WSL 的选择

选择一种运行模式并保持路径一致：

- 原生 Windows：桌面版使用 PowerShell；项目路径使用 `C:\...`，运行校验脚本使用 `.ps1`。
- WSL：在 WSL 中安装 Git、Node、Codex CLI 和依赖；项目使用 `/mnt/c/...` 或 WSL 内路径，`.sh` 脚本和 Codex CLI 都在 WSL 中运行。

不要在同一个任务中混用 Windows 路径、WSL 路径和两个环境各自的 `~/.codex`。若桌面版使用原生 Windows，优先把配置放在 Windows 用户目录；若 Codex CLI 在 WSL 中运行，使用 WSL 用户目录下的 `~/.codex/config.toml`。

### 桌面版日常使用配方

在新任务中先给 Sol 目标、约束和验收标准，例如：

```text
先读取 AGENTS.md，先由 luna_scout 只读盘点相关文件，再由 luna_worker 在指定范围内实施，最后由 luna_tester 验证。每个阶段通过后再解锁下一阶段。不要修改范围外文件，不要提交。
```

适合交给 Luna 的工作：文件定位、依赖盘点、边界清晰的实现、批量机械修改、测试和反向审查。Sol 应继续负责需求澄清、架构取舍、共享接口冲突、权限决定和最终验收。

在桌面版中检查子任务结果时，至少确认：Luna 使用了正确模型、没有越过任务卡范围、测试命令有退出结果、日志没有未收口错误、工作区 diff 符合预期。子代理会增加 token 和延迟，不要把所有小问题都拆成子任务。

### 常见故障排查

| 现象 | 优先检查 |
|---|---|
| 桌面版看不到项目规则 | 项目是否受信任；`AGENTS.md` 是否位于 Git 根目录；当前任务是否重新启动 |
| 桌面版不读取项目 `.codex` | 检查 `.codex/config.toml` 路径、项目信任状态和当前运行环境的用户目录 |
| `codex` 不是命令 | 安装 Codex CLI，或确认桌面版使用的运行环境与 CLI 所在环境一致 |
| `npx skills` 失败 | 检查 Node/npm、网络和技能安装目录；确认安装的是 `sdhack/sol-luna-setup` |
| `Unknown model gpt-5.6-luna` | 运行 catalog 脚本；检查 `model_catalog_json` 绝对路径和 `multi_agent_v2 = false`；重新启动任务 |
| `wire_api` 或 `/v1/responses` 错误 | 网关是否真的实现 Responses API；不要把 Chat Completions 端点伪装成 Responses |
| Luna 修改了不该改的文件 | 立即停止后续阶段，检查 sandbox/审批和任务卡；`AGENTS.md` 的角色文字不是强制隔离 |
| 配置修改后行为没变化 | 关闭并重新打开项目任务；确认没有更近目录的 `AGENTS.override.md` 或 `.codex/config.toml` 覆盖它 |

### 配置环境变量

只配置环境变量名，不把真实值写入配置文件：

```bash
export OPENAI_API_KEY="..."
```

推荐使用 OpenAI-compatible Responses 端点，并确认账号已启用 `gpt-5.6-sol` 与 `gpt-5.6-luna`。

## 验证

技能自身提供 PowerShell 校验：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\validate-setup.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\validate-role-definitions.ps1
```

Shell 语法检查：

```bash
bash -n scripts/bootstrap.sh
bash -n scripts/prepare-luna-catalog.sh
```

运行时冒烟：

```bash
codex exec --sandbox read-only -c 'model="gpt-5.6-sol"' \
  "Reply with exactly: SOL_SMOKE_OK" </dev/null

codex exec --sandbox read-only -c 'model="gpt-5.6-luna"' \
  "Reply with exactly: LUNA_SMOKE_OK" </dev/null
```

## 安全模型

永远不要把以下内容写入仓库：

- API Key、网关 Key、密码和私钥
- 主机 IP、SSH 凭据和个人访问令牌
- `.env`、生成的模型 catalog 和本地运行日志

校验脚本会检查关键文件、角色定义、疑似密钥和生产垃圾。真正的安全边界仍取决于运行环境权限；文档中的只读角色不能替代操作系统级隔离。

## 目录结构

```text
SKILL.md                         主技能协议
roles/*.yaml                     中立角色定义
references/project-template/     项目级 Codex/Claude 模板
references/*                     任务卡、闸门、回报和成本协议
scripts/bootstrap.sh             项目初始化
scripts/prepare-luna-catalog.sh  V1 catalog 生成
scripts/validate-setup.ps1       结构与脱敏校验
scripts/validate-role-definitions.ps1
```

## 设计原则

1. Sol 保留架构、授权和最终验收责任。
2. Luna 只执行当前阶段，不自行推进流程。
3. 阶段没有实际证据，不得解锁下一阶段。
4. 并行只在依赖独立、写入范围不重叠时启用。
5. 省 token 不能以降低测试标准和用户可见质量为代价。

## 参考

- [Anthropic: Building effective agents](https://www.anthropic.com/research/building-effective-agents)
- [LangGraph: Workflows and agents](https://docs.langchain.com/oss/python/langgraph/workflows-agents)
- [OpenAI: A practical guide to building agents](https://cdn.openai.com/business-guides-and-resources/a-practical-guide-to-building-agents.pdf)
- [本项目仓库](https://github.com/sdhack/sol-luna-setup)

## License

MIT
