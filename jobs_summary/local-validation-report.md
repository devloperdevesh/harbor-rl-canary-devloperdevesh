# Local Validation Report

- Passed: 7/7
- Failed: 0
- Method: Local Python subprocess tests against the solution extracted from `tasks/reconcile-bug/solution/solve.sh`.
- These are local validation results, not official Terminus-2 baseline or ablation results.

| Test | Result | Details |
|---|---|---|
| Original: CLI and status filtering | PASS |  |
| Original: decimal and malformed rows | PASS |  |
| Original: timezone-aware deduplication | PASS |  |
| Additional: missing input file | PASS |  |
| Additional: missing required CSV columns | PASS |  |
| Additional: empty and invalid rows | PASS |  |
| Additional: latest duplicate transaction wins | PASS |  |
