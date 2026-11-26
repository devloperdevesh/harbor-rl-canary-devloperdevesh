# Payment Reconciliation CLI

Implement `/app/reconcile.py` as a Python command-line program.

## Input

Accept one positional command-line argument: the path to a CSV file.

The CSV has these columns:

- tx_id
- timestamp
- amount
- status

Timestamps use ISO-8601 format and may contain timezone offsets.

## Output

Print exactly one JSON object to stdout with these keys:

- total_valid_amount
- valid_count
- failed_count

`total_valid_amount` must be rounded to two decimal places.

## Business requirements

1. SUCCESS transactions contribute to the valid amount and valid count.
2. FAILED transactions contribute to failed count.
3. Other statuses contribute to neither count.
4. Repeated transaction IDs represent one transaction. Retain the row with the latest timestamp.
5. Compare timestamps as actual instants, including timezone offsets.
6. Ignore malformed rows with missing required values, invalid timestamps, or non-numeric amounts.
7. Use decimal-safe arithmetic for money.
8. If the input file is missing or unreadable, exit non-zero and write a useful error to stderr.
9. Do not print debugging messages to stdout.
10. Preserve the exact output key names.

The implementation must work with Python 3.12 or newer.
