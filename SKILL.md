---
name: sol-luna-setup
description: |
  在新机器或新项目上落地「高智商领导 + 便宜执行」分层子代理：Codex Sol 领导 + Luna 工人，
  可选 Claude Code 项目级 agents 与 Pi/pi-flow 跨工具编排。用于：
  (1) 从零安装并配置 Codex / Claude Code / Pi
  (2) 写入项目级 .codex/agents、AGENTS.md、.claude/agents
  (3) 修复 Sol 无法 spawn Luna 的 multi-agent catalog 问题
  (4) 跑 Sol/Luna/多代理冒烟验证
  触发：新机器设置、Sol-Luna、分层子代理、multi-agent 配置、codex agents 初始化
---

# Sol + Luna 分层子代理 Setup Skill

> Install: `npx skills add Yuri-NagaSaki/subagent-skills -g -y`  
> Repo: https://github.com/Yuri-NagaSaki/subagent-skills  
> Guide: https://catcat.blog/2026/08/sol-luna-layered-subagents-codex-claude-pi.html

## 目标

在**不把密钥写入仓库**的前提下，让项目具备：

- 主会话 **gpt-5.6-sol**（领导）
- 工人 **gpt-5.6-luna**（scout / worker / critic / tester）
- 项目级配置可 git 共享
- 可验证的冒烟结果

## 硬性安全规则

1. **永远不要**把 API Key、主机 IP、SSH 密码、私钥写进 `config.toml`、`AGENTS.md`、README、文章正文或 git commit。
2. 密钥只用环境变量：`OPENAI_API_KEY` / `GATEWAY_API_KEY` / `ANTHROPIC_API_KEY` 等。
3. `model_providers.*.env_key` 只写变量**名**。
4. 大文件 `models-v1.json` 默认 gitignore，用脚本生成。

## 前置

- Linux / macOS，Node.js 20+
- 可访问的 OpenAI-compatible **Responses** 端点（`wire_api = "responses"`）
- 账号侧启用 `gpt-5.6-sol` 与 `gpt-5.6-luna`

## 标准流程（Agent 必须按序执行）

### 0. 探测

```bash
node -v && npm -v
command -v codex || true
command -v claude || true
command -v pi || true
test -n "${OPENAI_API_KEY:-}" && echo "OPENAI_API_KEY=set" || echo "OPENAI_API_KEY=MISSING"
```

若缺少 Key：停止并要求用户 export，**不要**在对话外落盘明文。

### 1. 安装 CLI

```bash
npm i -g @openai/codex @anthropic-ai/claude-code
# 可选
npm i -g @earendil-works/pi-coding-agent
# 或 curl -fsSL https://pi.dev/install.sh | sh
pi install npm:@kky42/pi-flow   # 可选，需已装 pi
```

### 2. 全局个人默认（可选）

写入 `~/.codex/config.toml`（仅个人默认）：

- `model = "gpt-5.6-sol"`
- `default_subagent_model = "gpt-5.6-luna"`
- `[features] multi_agent = true`，`multi_agent_v2 = false`（配合 V1 catalog）
- `[model_providers.gateway]` + `env_key = "OPENAI_API_KEY"`

**不要**复制用户的真实 Key 进文件。

### 3. 项目级模板

在项目根运行：

```bash
bash /path/to/subagent-skills/scripts/bootstrap.sh "$(pwd)"
# 或安装 skill 后:
# bash ~/.claude/skills/sol-luna-setup/scripts/bootstrap.sh "$(pwd)"
```

会创建/更新：

```text
.codex/config.toml
.codex/agents/luna_{scout,worker,critic,tester}.toml
AGENTS.md
.claude/agents/luna-{scout,worker,critic}.md
CLAUDE.md
scripts/prepare-luna-catalog.sh
.gitignore 条目：.codex/models-v1.json、.env
```

保留用户已有无关配置；冲突时合并而非盲覆盖。

### 4. 修复 Sol → Luna spawn（必做）

症状：

```text
Unknown model `gpt-5.6-luna` for spawn_agent.
Available models: gpt-5.6-sol, gpt-5.6-terra
```

原因：目录里 Sol/Terra 常为 multi-agent **v2**，Luna 为 **v1**，V2 过滤掉 Luna。

处理：

```bash
bash scripts/prepare-luna-catalog.sh "$(pwd)/.codex/models-v1.json"
# 将 model_catalog_json 设为该文件的绝对路径
# multi_agent_v2 = false
```

### 5. 验证（必须全部通过再宣称完成）

```bash
# 单模型（注意 </dev/null）
codex exec --sandbox read-only -c 'model="gpt-5.6-sol"' \
  "Reply with exactly: SOL_SMOKE_OK" </dev/null

codex exec --sandbox read-only -c 'model="gpt-5.6-luna"' \
  "Reply with exactly: LUNA_SMOKE_OK" </dev/null

# 多代理
codex exec --sandbox read-only \
  "按 AGENTS.md spawn luna_scout 只读说明仓库结构，输出以 SCOUT_DONE 开头" </dev/null

# 可选 Pi
export GATEWAY_API_KEY="${OPENAI_API_KEY}"
pi --print --provider gateway --model gpt-5.6-sol --no-session --no-tools "Reply: PI_SOL_OK"
pi --print --provider gateway --model gpt-5.6-luna --no-session --no-tools "Reply: PI_LUNA_OK"
```

Claude Code：

- 非 root 用户更稳妥
- 对 haiku 做一次 `claude -p` 冒烟；若网关 Anthropic 通道 502，记录为供应商问题，仍可提交 agents 文件

### 6. 交付报告模板

```markdown
## Sol-Luna Setup Report
- Host OS / Node / Codex / Claude / Pi versions:
- Project path:
- Files created:
- Catalog fix applied: yes/no
- SOL_SMOKE: pass/fail
- LUNA_SMOKE: pass/fail
- MULTI_AGENT SCOUT_DONE: pass/fail
- Pi SOL/LUNA: pass/fail/skip
- Secrets in git: none (confirmed)
- Next user action:
```

## 第一阶段协议：Sol 领导，Luna 执行

本节是项目级协作协议，适用于需要修改代码、配置、文档或运行测试的任务。它只规定任务分工、证据和验收，不实现调度脚本。

### 角色政策（写入 AGENTS.md）

| 角色 | 模型 | 权限与责任 |
|------|------|------------|
| 主会话 Sol | `gpt-5.6-sol` | 需求理解、架构决策、阶段拆解、调度、整合、独立验收、commit/PR/发布 |
| `luna_scout` | `gpt-5.6-luna` | 只读探索代码库、依赖、日志和文档，返回可核验事实 |
| `luna_worker` | `gpt-5.6-luna` | 在明确文件范围内实现当前阶段，禁止改变架构目标、提交或发布 |
| `luna_critic` | `gpt-5.6-luna` | 只读对抗审查正确性、安全、回归风险和测试缺口 |
| `luna_tester` | `gpt-5.6-luna` | 按指定计划运行测试、检查产物并返回原始证据 |

### Sol 默认委派原则

Sol 先判断任务的风险、边界和独立验证方式，再决定是否委派。满足任一条件时，默认将可限定的落地工作交给一个 Luna：涉及两个以上文件、预计超过 2 分钟、需要重复机械操作、需要独立测试或对抗审查，或存在清晰的文件/目录边界。

Sol 不委派需求理解、架构设计、跨模块取舍、最终验收、commit、PR、发布或需要用户授权的破坏性操作。单条只读命令、单文件几行以内的明确修改、纯问答和简单状态查询可由 Sol 直接处理。委派不改变 Sol 的最终决策权，也不把责任转移给 Luna。

### 任务分流矩阵

| 任务 | 默认执行者 | 权限 | 必须返回的证据 |
|------|------------|------|----------------|
| 搜索文件、读取文档、盘点依赖、定位代码 | `luna_scout` | read-only | 文件路径、关键行/事实、命令和限制 |
| 简单增删改查、单文件小修复、格式调整 | `luna_worker` | workspace-write | 修改文件、实际 diff、定向检查结果 |
| 批量机械修改、模板生成、数据整理 | `luna_worker` | workspace-write | 输入/输出数量、唯一 ID 或顺序核对、残留检查 |
| 运行测试、类型检查、产物核验 | `luna_tester` | workspace-write | 完整命令、退出码、关键输出、错误日志 |
| 安全审查、回归检查、测试缺口分析 | `luna_critic` | read-only | 按严重度列出问题、路径/行号、复现或推理依据 |
| 需求理解、架构设计、跨模块取舍、最终验收、commit/PR/发布 | Sol | 主会话 | 决策记录、闸门证据和用户可见结果 |

默认只派 1 个 Luna。只有阶段输入、输出和写入文件彼此独立，且不存在共享状态、顺序依赖或同文件写入时，才允许并行，最多 3 个 Luna；并行阶段必须分别有任务卡和验收闸门。共享文件、共享生成物或需要前一阶段结论的任务必须串行。

### 阶段 DAG 与闸门

Sol 在派发前建立阶段状态表，每个阶段只能有一个当前状态：

| 阶段 | 依赖 | 输入 | 输出 | 执行者 | 状态 | 闸门证据 | 解锁时间 |
|------|------|------|------|--------|------|----------|----------|
| 盘点 | 无 | 用户请求、仓库状态 | 范围、风险、任务卡 | Sol / `luna_scout` | pending/in_progress/completed | 实际路径、现状和边界检查 | ISO 8601 |
| 实现 | 盘点通过 | 已确认文件范围 | 修改文件和 diff | `luna_worker` | pending/in_progress/completed | diff、语法/类型或定向检查 | ISO 8601 |
| 验证 | 实现通过 | 实际产物和测试计划 | 测试/核验结果 | `luna_tester` / `luna_critic` | pending/in_progress/completed | 命令、退出码、日志、数量/顺序 | ISO 8601 |
| Sol 验收 | 验证通过 | 全部阶段证据 | 用户可见交付结论 | Sol | pending/in_progress/completed | 独立 diff、范围、残留和安全检查 | ISO 8601 |

阶段按 DAG 解锁：无依赖阶段先行；依赖阶段只有在前置闸门证据实际通过后才能开始。出现 `error`、未收口的失败重试、产物数量/唯一 ID/索引/顺序矛盾、关键产物缺失或只能凭推测确认时，闸门失败，停止后续阶段。

失败阶段最多向同一个 Luna 回派 2 次最小修复；每次回派必须附失败证据和单一修复目标。两次仍未通过时，Sol 接管最小修复或重新拆分任务，不得无限重试，也不得用降级、跳过或伪造结果放行。

### 上下文与成本控制

- Sol 只向 Luna 提供完成当前阶段所需的文件、接口、约束和前置证据；不注入整份历史对话或无关大文件。
- 优先使用 `rg`、定点读取、结构化输出和摘要；大输出保存为可定位的日志或摘要，不在后续任务中重复粘贴。
- 每个 Luna 任务只覆盖当前阶段，有明确结束条件；回报后停止，不保持无意义的后台进程。
- 简单 CRUD 默认 `medium` 或 `high` 推理强度；只有复杂修复在任务卡中说明理由后才使用 `max`。
- 以“每阶段 token/时间预算、有效产出、返工次数、测试通过率、缺陷逃逸数”衡量成本质量；降低 token 不能牺牲闸门证据和用户可见行为。

### Luna 任务卡与回报契约

每次委派必须使用以下字段：

```text
角色：Luna 执行
目标：一句话说明当前阶段的交付结果
范围：允许修改或读取的文件/目录
输入：前置闸门证据、接口、样本或用户约束
验收：可执行的测试、输出或行为标准
约束：不越界、不备份、不产生临时文件、不提交、不发布、不处理密钥
回报：修改文件；命令/退出码/关键结果；输入输出数量；错误日志；风险；未完成项
```

Luna 必须只执行当前阶段，发现问题先在本阶段内读取代码、运行检查和验证；只有真实外部阻塞或缺少用户选择才上报。回报后立即停止，不能自行推进下一阶段。

### Sol 独立验收责任

Luna 回报后，Sol 必须独立检查实际 diff、文件范围、测试命令与退出码、错误日志、残留文件、输入输出数量、唯一 ID/索引/顺序、依赖顺序、接口调用链、错误处理和用户可见行为。仅凭 Luna 的文字总结不能判定完成；未写入闸门证据并标记通过前，不得解锁下一阶段或向用户宣称完成。

## Sol 路由协议

凡是能够被清晰限定、执行、测试和审查的工作，默认交给 Luna。Sol 保留需求理解、架构决策、冲突整合、风险判断、最终验收及 commit/PR/发布。

复杂任务按 `luna_scout -> luna_worker -> luna_tester -> luna_critic -> Sol` 执行。阶段未通过不得解锁下一阶段；失败最多回派两次。默认只派一个 Luna，只有依赖独立且写入集合不重叠时才并行。不得多个 Agent 同时修改同一文件。

每次派发只传当前阶段必要上下文：scout 返回摘要，worker 接收摘要和相关文件，tester 接收变更范围与验收命令，critic 接收 diff、测试结果和风险背景。Luna 不改变总体架构、不提交或发布、不处理密钥、不自行推进下一阶段。

任务卡和阶段闸门见 `references/task-card.md`、`references/stage-gates.md`、`references/reporting-contract.md`。

## 常见失败

| 现象 | 处理 |
|------|------|
| spawn 无 Luna | V1 catalog + multi_agent_v2=false |
| codex 吞掉后续 shell | `codex exec ... </dev/null` |
| wire_api 报错 | 使用 `responses`；确认网关实现 `/v1/responses` |
| Claude root 拒绝 bypass | 换非 root 或降低 permission mode |
| 工人写冲突 | 降并发、按文件分区 |
| 密钥进 diff | 立即剔除、轮换密钥 |

## 参考文件

- `scripts/bootstrap.sh` — 项目脚手架
- `scripts/prepare-luna-catalog.sh` — 模型目录修复
- `references/project-template/` — 可复制模板
- `references/routing-protocol.md` — 默认委派、分流矩阵、阶段 DAG 与并行条件
- `references/task-card.md` — Luna 任务卡和失败回派卡
- `references/stage-gates.md` — 阶段状态表、闸门标准与 Sol 验收清单
- `references/reporting-contract.md` — Luna 回报字段与状态语义
- `references/cost-quality-metrics.md` — 上下文、成本、质量和返工指标
- 博客长文：https://catcat.blog/2026/08/sol-luna-layered-subagents-codex-claude-pi.html
- 源仓库：https://github.com/Yuri-NagaSaki/subagent-skills

## Agent 行为准则

- 先探测、再安装、再写项目文件、再修 catalog、再验证。
- 展示关键 diff；不覆盖无关用户配置。
- 验证失败时给出可执行修复，不要假装成功。
- 用户若要求「只配置 Sol 和 Luna」：不要启用 Terra 作为默认，catalog 里可保留 Terra 条目仅用于兼容。
---
