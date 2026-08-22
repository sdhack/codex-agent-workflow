# Cost and Quality Metrics

Use metrics to control context and rework without weakening acceptance evidence. Record them per stage when the task is large enough to justify measurement.

| Metric | Definition | Quality signal |
|---|---|---|
| Stage elapsed time | Time from dispatch to report | Detects stalled or oversized stages |
| Context volume | Input and output tokens or bounded byte counts | Detects unnecessary history and log repetition |
| Delegation ratio | Bounded execution stages delegated / eligible execution stages | Shows whether Sol is keeping decision work while using Luna for execution |
| Repair count | Repair dispatches for the stage, maximum 2 | Exposes unclear cards or unstable changes |
| Verification pass rate | Required checks passed / required checks run | Must be 100% for a passed gate |
| Defect escape count | Issues found after a gate was marked passed | Must remain 0; any escape triggers review of the gate |
| Scope violations | Changed paths outside the card | Must be 0 |
| Artifact integrity | Counts, unique IDs, indexes, and ordering consistent | Must be true where applicable |

## Minimum acceptance

Never trade away syntax/type checks, required tests, error-log review, scope inspection, or user-visible behavior checks to reduce context. Prefer targeted reads, exact line references, structured summaries, and one focused repair over repeated full-context retries.

