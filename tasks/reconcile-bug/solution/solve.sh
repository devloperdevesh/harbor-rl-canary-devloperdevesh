#!/bin/bash
set -euo pipefail

cat > /app/reconcile.py <<'PY'
#!/usr/bin/env python3
import argparse
import csv
import json
import sys
from datetime import datetime, timezone
from decimal import Decimal, InvalidOperation, ROUND_HALF_UP

def parse_timestamp(value):
    value = value.strip()
    if value.endswith("Z"):
        value = value[:-1] + "+00:00"
    dt = datetime.fromisoformat(value)
    if dt.tzinfo is None:
        dt = dt.replace(tzinfo=timezone.utc)
    return dt.astimezone(timezone.utc)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("csv_path")
    args = parser.parse_args()

    latest = {}

    with open(args.csv_path, newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        required = {"tx_id", "timestamp", "amount", "status"}
        if not reader.fieldnames or not required.issubset(reader.fieldnames):
            raise ValueError("CSV is missing required columns")

        for row in reader:
            try:
                tx = (row.get("tx_id") or "").strip()
                status = (row.get("status") or "").strip().upper()
                amount = Decimal((row.get("amount") or "").strip())
                stamp = parse_timestamp(row.get("timestamp") or "")

                if not tx or not status or not amount.is_finite():
                    continue

                if tx not in latest or stamp > latest[tx][0]:
                    latest[tx] = (stamp, status, amount)
            except (ValueError, TypeError, InvalidOperation, OverflowError):
                continue

    total = Decimal("0")
    valid = 0
    failed = 0

    for _, status, amount in latest.values():
        if status == "SUCCESS":
            total += amount
            valid += 1
        elif status == "FAILED":
            failed += 1

    total = total.quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)

    print(json.dumps({
        "total_valid_amount": float(total),
        "valid_count": valid,
        "failed_count": failed
    }))

if __name__ == "__main__":
    try:
        main()
    except (OSError, csv.Error, ValueError) as exc:
        print(f"reconcile: {exc}", file=sys.stderr)
        sys.exit(2)
PY

chmod +x /app/reconcile.py
