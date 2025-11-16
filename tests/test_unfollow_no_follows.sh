#!/bin/bash
# Test: Unfollow no follows dry-run
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

echo "Running atproto unfollow-no-follows dry-run with report..."
TMP_REPORT="$(mktemp -t atproto_unfollow_report_XXXX.csv)"
if ! ./bin/atproto unfollow-no-follows --dry-run --limit 5 --report-file "$TMP_REPORT"; then
    echo "Dry-run failed or requires authentication"
    rm -f "$TMP_REPORT"
    exit 1
fi

entries=$(wc -l < "$TMP_REPORT" | tr -d ' ')
if [ "$entries" -le 1 ]; then
    echo "Unexpected report content: $entries lines (header + entries expected)"
    rm -f "$TMP_REPORT"
    exit 1
fi

echo "Report generated: $TMP_REPORT ($entries lines)"

echo "Running again with --resume to verify skipping processed entries..."
if ! ./bin/atproto unfollow-no-follows --dry-run --limit 5 --report-file "$TMP_REPORT" --resume; then
    echo "Resume dry-run failed"
    rm -f "$TMP_REPORT"
    exit 1
fi

echo "Test passed: dry-run resume executed successfully"
rm -f "$TMP_REPORT"
exit 0
