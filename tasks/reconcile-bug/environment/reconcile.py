#!/usr/bin/env python3
import argparse
import csv
import json
from datetime import datetime

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--csv", required=True)
    args = parser.parse_args()

    latest = {}

    with open(args.csv, newline="", encoding="utf-8") as f:
        for row in csv.DictReader(f):
            try:
                tx = row["tx_id"].strip()
                stamp = row["timestamp"].strip()
                amount = float(row["amount"])
                status = row["status"].strip().upper()

                if not tx:
                    continue

                # Baseline implementation intentionally needs debugging.
                if tx not in latest or stamp > latest[tx][0]:
                    latest[tx] = (stamp, amount, status)
            except (ValueError, KeyError, TypeError):
                continue

    total = 0.0
    valid = 0
    failed = 0

    for _, amount, status in latest.values():
        if status in ("SUCCESS", "PENDING"):
            total += amount
            valid += 1
        elif status == "FAILED":
            failed += 1

    print(json.dumps({
        "total_valid_amount": round(total, 2),
        "valid_count": valid,
        "failed_count": failed
    }))

if __name__ == "__main__":
    main()
