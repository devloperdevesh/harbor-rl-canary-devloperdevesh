# Harbor RL Canary — Payment Reconciliation

## Project overview

A Harbor coding task focused on debugging a payment reconciliation CLI. The task evaluates transaction status handling, decimal arithmetic, malformed rows, and timezone-aware deduplication.

## Task structure

- `tasks/reconcile-bug/` — primary task, environment, reference solution, reward-hacking attempt, and verifier.
- `tasks/reconcile-bug-ablation/` — controlled instruction-clarity ablation variant.
- `jobs_summary/` — selected experiment and verifier-validation evidence.
- `ai_transcripts/` — transcript-export status and available agent logs.

## Verifier design

The original binary verifier gives reward 1.0 only when all three checks pass; otherwise it gives 0.0.

The dense verifier assigns independent weights:

| Check | Weight |
|---|---:|
| CLI and transaction statuses | 0.3333 |
| Decimal arithmetic and malformed rows | 0.3333 |
| Timezone-aware deduplication | 0.3334 |
| **Total** | **1.0000** |

Dense reward is the sum of the weights for passed checks.

## Verifier validation

Actual Harbor Oracle validation results:

| Validation | Trials | Exceptions | Mean reward |
|---|---:|---:|---:|
| Correct reference solution | 1 | 0 | 1.0000 |
| Hardcoded-output reward hack | 1 | 0 | 0.0000 |
| Controlled partial solution | 1 | 0 | 0.6666 |

The partial validation changed timezone normalization in a temporary task copy. The original task remained unchanged. These checks demonstrate full reward for the reference solution, rejection of the tested hardcoded-output hack, and partial credit for partial correctness.

Evidence: `jobs_summary/verifier-validation/`.

## Local Qwen-Coder experiments

The same local Qwen-Coder 7B model was used for three baseline trials and three instruction-clarity ablation trials. All six trials completed without Harbor exceptions, but all received zero reward.

| Experiment | Trial | Binary reward | Dense reward | Binary advantage | Dense advantage |
|---|---|---:|---:|---:|---:|
| Baseline | reconcile-bug__apyAaF9 | 0 | 0.0000 | 0.0000 | 0.0000 |
| Baseline | reconcile-bug__gEybCUu | 0 | 0.0000 | 0.0000 | 0.0000 |
| Baseline | reconcile-bug__QmoJ3Xf | 0 | 0.0000 | 0.0000 | 0.0000 |
| Instruction-clarity ablation | reconcile-bug-ablation__DRiQ3Ny | 0 | 0.0000 | 0.0000 | 0.0000 |
| Instruction-clarity ablation | reconcile-bug-ablation__UMzZvnH | 0 | 0.0000 | 0.0000 | 0.0000 |
| Instruction-clarity ablation | reconcile-bug-ablation__xvihSFp | 0 | 0.0000 | 0.0000 | 0.0000 |

Advantage calculation:

`Advantage = Trial reward - Mean reward of that experiment`

Both experiment groups have mean reward 0.0, so every trial has zero advantage. The ablation did not improve measured task performance.

These are local Qwen-Coder experiments, not official terminus-2 baseline results.

## Terminus-2 endpoint limitation

Two local Terminus-2 wrapper diagnostics were attempted with Ollama/Qwen2.5-Coder 7B. The first attempt using `host.docker.internal:11434` failed to connect and used zero tokens. The second attempt using `127.0.0.1:11434` reached the local model and generated 9,888 prompt tokens and 1,462 completion tokens, but the agent timed out after 600 seconds. Its trajectory records JSON parser warnings, unnecessary editor installation, incorrect Vim interaction, and faulty generated code. This was a diagnostic run using a local Qwen model through the Terminus-2 wrapper, not an official Terminus-2 model evaluation.

The required terminus-2 baseline and terminus-2 ablation have therefore not been completed.

## Trajectory observations

The local agent trials showed implementation failures including malformed generated Python, incorrect decimal precision handling, incomplete timezone normalization, and CSV parsing or output-format issues. See the saved per-trial trajectories and agent output logs for the actual evidence.

## Reward-hacking analysis

The tested hardcoded-output solution received 0.0000 from the dense verifier, while the reference solution received 1.0000. This validates rejection of that specific attack; it does not prove immunity to every possible reward-hacking strategy.

## AI coding-tool transcripts

Available per-trial agent output files are preserved separately from Harbor trajectories. They are not represented as exported interactive chat histories. A genuine coding-tool chat transcript export remains outstanding.

## Loom walkthrough

Not yet recorded. Add the real, publicly accessible Loom URL here after recording the demonstration.

## Reproducibility and evidence

- Task lint passed: `harbor lint tasks/reconcile-bug --json` returned `[]`.
- Six local Qwen-Coder trial records: `jobs_summary/qwen-coder-baseline-3/` and `jobs_summary/qwen-coder-ablation-3/`.
- Dense verifier validation: `jobs_summary/verifier-validation/`.
- Trial reward and advantage data: `jobs_summary/dense-trial-advantages.json` and `jobs_summary/trial-results.csv`.

## Limitations

This submission records the experiments that actually ran. The required terminus-2 baseline, terminus-2 ablation, genuine chat transcript export, and Loom demonstration remain incomplete. No results are fabricated or attributed to a different agent.

## Demo Video

[Watch the Harbor RL Canary walkthrough on Loom](https://www.loom.com/share/c9eb646b94f044b6a45d892446efd780)
