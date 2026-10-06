#!/usr/bin/env bash
set -euo pipefail

# run-comparison.sh — Run a comparison between two profiles.
# Usage: ./run-comparison.sh <profile-a> <profile-b> [case]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPARISON_DIR="$(dirname "$SCRIPT_DIR")"
PIQUE_ROOT="$(dirname "$COMPARISON_DIR")"

PROFILE_A="${1:?Specify first profile}"
PROFILE_B="${2:?Specify second profile}"
CASE="${3:-code-quality}"

CASE_DIR="$COMPARISON_DIR/cases/$CASE"

if [ ! -d "$CASE_DIR" ]; then
    echo "Error: case '$CASE' not found in $COMPARISON_DIR/cases/" >&2
    echo "Available cases:" >&2
    ls -1 "$COMPARISON_DIR/cases/" 2>/dev/null | sed 's/^/  /' >&2
    exit 1
fi

if [ ! -f "$CASE_DIR/prompt.md" ]; then
    echo "Error: prompt.md not found in $CASE_DIR" >&2
    exit 1
fi

PROMPT="$(cat "$CASE_DIR/prompt.md")"
TIMESTAMP="$(date +%Y-%m-%d)"
RESULTS_DIR="$COMPARISON_DIR/results"
RESULT_FILE="$RESULTS_DIR/${TIMESTAMP}_${PROFILE_A}_vs_${PROFILE_B}_${CASE}.md"

mkdir -p "$RESULTS_DIR"

echo "=== Running comparison: $PROFILE_A vs $PROFILE_B ==="
echo "Case: $CASE"
echo "Output: $RESULT_FILE"
echo ""

{
    echo "# Comparison: $PROFILE_A vs $PROFILE_B"
    echo ""
    echo "- **Date**: $TIMESTAMP"
    echo "- **Case**: $CASE"
    echo "- **Profiles**: $PROFILE_A, $PROFILE_B"
    echo ""
    echo "## Prompt"
    echo ""
    echo '```'
    echo "$PROMPT"
    echo '```'
    echo ""
    
    for PROFILE in "$PROFILE_A" "$PROFILE_B"; do
        echo "---"
        echo "## Response from: $PROFILE"
        echo ""
        echo "Run:"
        echo '```bash'
        echo "pique $PROFILE --print \"$PROMPT\""
        echo '```'
        echo ""
        echo "<!-- Paste response here -->"
        echo ""
    done
    
    echo "---"
    echo "## Evaluation"
    echo ""
    echo "<!-- Compare responses and record findings -->"
    echo ""
    echo "## Conclusion"
    echo ""
    echo "<!-- Which profile performed better and why -->"
} > "$RESULT_FILE"

echo "Template created: $RESULT_FILE"
echo ""
echo "Next steps:"
echo "  1. Run each profile with the prompt"
echo "  2. Paste responses into the template"
echo "  3. Fill in evaluation and conclusion"
echo "  4. Commit the result"
