#!/usr/bin/env bash
#
# Tests for validate-artifact.sh. Builds complete and deliberately-incomplete
# fixture artifacts under a temp docs/ tree and asserts the hook's warnings.
#
# Run: hooks/test-validate-artifact.sh   (exit 0 = all pass)
#
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
readonly SCRIPT_DIR
readonly SUT="$SCRIPT_DIR/validate-artifact.sh"

TMP=$(mktemp -d)
readonly TMP
cleanup() { rm -rf "$TMP"; }
trap cleanup EXIT INT TERM

pass=0
fail=0

# Run the SUT against a file and capture stdout.
run_on() { "$SUT" --file "$1"; }

assert_empty() {
  local desc="$1" out="$2"
  if [[ -z "$out" ]]; then
    printf 'ok   - %s\n' "$desc"
    pass=$((pass + 1))
  else
    printf 'FAIL - %s (expected no warning, got: %s)\n' "$desc" "$out"
    fail=$((fail + 1))
  fi
}

assert_contains() {
  local desc="$1" out="$2" needle="$3"
  if [[ "$out" == *"$needle"* ]]; then
    printf 'ok   - %s\n' "$desc"
    pass=$((pass + 1))
  else
    printf 'FAIL - %s (expected to contain %q, got: %s)\n' "$desc" "$needle" "$out"
    fail=$((fail + 1))
  fi
}

write_file() {
  local path="$1"
  mkdir -p -- "${path%/*}"
  cat >"$path"
}

# --- Fixtures -------------------------------------------------------------

write_file "$TMP/docs/prd/complete.md" <<'EOF'
# PRD: Complete
## Problem statement
x
## Goals & non-goals
goals here, non-goals here
## Success metrics
p95
## Non-functional requirements
nfr
EOF

write_file "$TMP/docs/prd/incomplete.md" <<'EOF'
# PRD: Incomplete
## Goals
some goals
EOF

write_file "$TMP/docs/adr/0001-complete.md" <<'EOF'
# Use Postgres
## Status
Accepted
## Context and Problem Statement
ctx
## Decision Drivers
- d
## Considered Options
- a
- b
## Decision Outcome
chose a
### Consequences
good/bad
EOF

write_file "$TMP/docs/adr/0002-incomplete.md" <<'EOF'
# Use Kafka
## Status
Accepted
## Context
ctx
## Considered Options
- a
EOF

write_file "$TMP/docs/architecture/complete.md" <<'EOF'
# Architecture: Complete
## Structure
components
## Non-functional requirements
nfr strategy
## Trade-offs
options considered, alternatives
EOF

write_file "$TMP/docs/architecture/incomplete.md" <<'EOF'
# Architecture: Incomplete
## Structure
just components
EOF

# Exempt / non-artifact files
write_file "$TMP/docs/architecture/current-state.md" <<'EOF'
# Current state
just a map, no NFR or trade-off sections
EOF

write_file "$TMP/src/notes.md" <<'EOF'
# Random notes
not an artifact
EOF

# --- Assertions -----------------------------------------------------------

assert_empty    "complete PRD passes silently"            "$(run_on "$TMP/docs/prd/complete.md")"
out=$(run_on "$TMP/docs/prd/incomplete.md")
assert_contains "incomplete PRD flags Success metrics"    "$out" "Success metrics"
assert_contains "incomplete PRD flags Non-functional"     "$out" "Non-functional requirements"
assert_contains "incomplete PRD flags Non-goals"          "$out" "Non-goals"

assert_empty    "complete ADR passes silently"            "$(run_on "$TMP/docs/adr/0001-complete.md")"
out=$(run_on "$TMP/docs/adr/0002-incomplete.md")
assert_contains "incomplete ADR flags Decision Drivers"   "$out" "Decision Drivers"
assert_contains "incomplete ADR flags Decision Outcome"   "$out" "Decision Outcome"
assert_contains "incomplete ADR flags Consequences"       "$out" "Consequences"

assert_empty    "complete architecture passes silently"   "$(run_on "$TMP/docs/architecture/complete.md")"
out=$(run_on "$TMP/docs/architecture/incomplete.md")
assert_contains "incomplete arch flags Trade-offs"        "$out" "Trade-offs / alternatives"
assert_contains "incomplete arch flags Non-functional"    "$out" "Non-functional requirements"

assert_empty    "current-state.md is exempt"              "$(run_on "$TMP/docs/architecture/current-state.md")"
assert_empty    "non-artifact file is ignored"            "$(run_on "$TMP/src/notes.md")"

# --- Summary --------------------------------------------------------------

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[[ "$fail" -eq 0 ]]
