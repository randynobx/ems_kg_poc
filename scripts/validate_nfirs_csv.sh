#!/bin/sh

# Usage: ./validate_nfirs_csv.sh <csv_file>

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <csv_file>"
    exit 1
fi

CSV_FILE="$1"

# Run the Python validator
python3 -m web_backend.app.utils.validation "$CSV_FILE"
STATUS=$?

if [ "$STATUS" -eq 0 ]; then
    echo "CSV validation successful."
    exit 0
else
    echo "CSV validation failed."
    exit $STATUS
fi
