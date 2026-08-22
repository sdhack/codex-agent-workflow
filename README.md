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
npx skills add Yuri-NagaSaki/subagent-skills -g -y
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
- [原始 Sol/Luna 实践仓库](https://github.com/Yuri-NagaSaki/subagent-skills)

## License

MIT
