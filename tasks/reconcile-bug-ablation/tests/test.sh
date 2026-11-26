#!/bin/bash
set -euo pipefail

mkdir -p /logs/verifier

python3 - <<'PY'
import csv
import json
import os
import subprocess
import sys
import tempfile

program = "/app/reconcile.py"
checks = []

def run_case(rows, expected, name):
    path = None
    try:
        with tempfile.NamedTemporaryFile(
            mode="w", suffix=".csv", newline="", delete=False
        ) as f:
            writer = csv.writer(f)
            writer.writerow(["tx_id", "timestamp", "amount", "status"])
            writer.writerows(rows)
            path = f.name

        result = subprocess.run(
            [sys.executable, program, path],
            capture_output=True,
            text=True,
            timeout=10,
        )

        if result.returncode != 0:
            raise AssertionError(f"non-zero exit: {result.stderr}")

        data = json.loads(result.stdout)
        if set(data) != {
            "total_valid_amount", "valid_count", "failed_count"
        }:
            raise AssertionError("incorrect output keys")

        if data != expected:
            raise AssertionError(f"expected {expected}, got {data}")

        checks.append((name, True))
    except Exception as exc:
        checks.append((name, False))
        print(f"FAIL {name}: {exc}")
    finally:
        if path and os.path.exists(path):
            os.unlink(path)

# Check 1: CLI, status filtering and aggregation.
run_case([
    ["a", "2026-01-01T10:00:00Z", "17.35", "SUCCESS"],
    ["b", "2026-01-01T11:00:00Z", "4.25", "FAILED"],
    ["c", "2026-01-01T12:00:00Z", "99.99", "PENDING"],
], {
    "total_valid_amount": 17.35,
    "valid_count": 1,
    "failed_count": 1
}, "cli_and_statuses")

# Check 2: decimal arithmetic and malformed-row handling.
run_case([
    ["a", "2026-01-02T10:00:00Z", "0.10", "SUCCESS"],
    ["b", "2026-01-02T11:00:00Z", "0.20", "SUCCESS"],
    ["c", "not-a-date", "500", "SUCCESS"],
    ["d", "2026-01-02T12:00:00Z", "not-money", "SUCCESS"],
], {
    "total_valid_amount": 0.3,
    "valid_count": 2,
    "failed_count": 0
}, "decimal_and_malformed_rows")

# Check 3: compare timestamps by UTC instant, not string order.
run_case([
    ["x", "2026-01-01T10:00:00+02:00", "100.00", "SUCCESS"],
    ["x", "2026-01-01T09:00:00Z", "7.00", "FAILED"],
], {
    "total_valid_amount": 0.0,
    "valid_count": 0,
    "failed_count": 1
}, "timezone_aware_deduplication")

weights = {
    "cli_and_statuses": 0.3333,
    "decimal_and_malformed_rows": 0.3333,
    "timezone_aware_deduplication": 0.3334,
}

for name, passed in checks:
    print(("PASS " if passed else "FAIL ") + name)

reward = sum(weights[name] for name, passed in checks if passed)
reward = round(reward, 4)

print(f"Verifier checks: {sum(p for _, p in checks)}/{len(checks)}")
print(f"Dense reward: {reward:.4f}")

with open("/logs/verifier/reward.txt", "w") as f:
    f.write(f"{reward:.4f}\n")

if reward < 0.9999:
    sys.exit(1)
PY
