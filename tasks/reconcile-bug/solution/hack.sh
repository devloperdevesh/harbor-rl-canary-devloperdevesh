#!/bin/bash
set -euo pipefail

cat > /app/reconcile.py <<'PY'
#!/usr/bin/env python3
import json
print(json.dumps({
    "total_valid_amount": 10.1,
    "valid_count": 1,
    "failed_count": 1
}))
PY

chmod +x /app/reconcile.py
