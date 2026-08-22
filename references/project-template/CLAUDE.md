# Claude Code 多代理政策

- 主会话使用最强可用模型（领导层）：规划、审核、整合、兜底。
- 执行层优先调用 `.claude/agents/` 下的 luna-* 子代理（haiku 或账号内最便宜模型）。
- 失败或质量不达标立即 escalate 回主会话。
- commit / PR / 部署永远由主会话控制。
