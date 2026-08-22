# Sol-Luna Routing Protocol

## Purpose

Use this protocol to route a bounded engineering task between one Sol lead and Luna executors. It is a coordination contract, not an implementation script.

## Default route

Sol owns requirements, architecture, tradeoffs, user authorization, integration, independent acceptance, commit, PR, and release. Sol should delegate bounded execution to one Luna when the task spans multiple files, is likely to take more than two minutes, is repetitive, needs an independent test, or has a clear file boundary.

Sol may handle a one-line read-only check, a tiny unambiguous edit, a simple status query, or a pure explanation directly. Delegation never transfers final responsibility.

## Matrix

| Work | Luna role | Access | Evidence |
|---|---|---|---|
| Repository and dependency discovery | `luna_scout` | read-only | Paths, facts, commands, limits |
| Bounded implementation or mechanical transformation | `luna_worker` | workspace-write | Diff, checks, changed files |
| Test and artifact verification | `luna_tester` | workspace-write | Command, exit code, logs, counts/order |
| Security and regression challenge | `luna_critic` | read-only | Severity, location, reproduction or reasoning |
| Architecture and final acceptance | Sol | main session | Decision and gate evidence |

## Stage DAG

The default dependency graph is:

```text
inventory -> implementation -> verification -> Sol acceptance
```

Only a stage with a passed gate may unlock its dependents. Record `stage`, `dependencies`, `inputs`, `outputs`, `executor`, `status`, `gate evidence`, and `unlock time`.

## Parallelism

Use one Luna by default. Parallel work is allowed only when inputs, outputs, write targets, and validation are independent, with no shared state or order dependency. Cap parallel Luna tasks at three. Never allow two workers to write the same file or generated artifact.

## Failure rule

For a failed stage, send the same Luna a minimal repair card no more than twice. Include the observed failure and one repair objective. After two unsuccessful repairs, Sol takes the smallest fix or replans; it must not silently skip the gate.

## Context rule

Send only current-stage inputs and constraints. Prefer targeted search, line references, structured summaries, and bounded logs. Do not repeat full history or large files. End the Luna task after its report.

