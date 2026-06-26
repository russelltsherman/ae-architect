#!/usr/bin/env bash
#
# validate-artifact.sh — PostToolUse hook for the ae-architect plugin.
#
# Fires after Write/Edit. If the touched file is an ae-architect design artifact
# (a PRD, ADR, or architecture doc under docs/), it checks for the structural
# sections that artifact type is expected to contain and emits a NON-BLOCKING
# warning listing anything missing. It never blocks the edit — the goal is to
# nudge completeness, consistent with the flexible-toolkit design.
#
# Usage:
#   - As a hook: reads the PostToolUse JSON event on stdin.
#   - For tests/manual: validate-artifact.sh --file <path>
#
set -euo pipefail
IFS=$'\n\t'

warn() { printf '%s\n' "$*" >&2; }
die() { warn "$*"; exit 2; }

# Map an artifact path to its type. Echoes prd|adr|architecture, or nothing if the
# path is not an ae-architect artifact (so non-artifact edits are silently ignored).
# The cartographer's current-state map is intentionally exempt — it has its own shape.
artifact_type_for_path() {
  local path="$1"
  local base="${path##*/}"
  case "$path" in
    */docs/prd/*.md | docs/prd/*.md) printf 'prd' ;;
    */docs/adr/*.md | docs/adr/*.md)
      # Skip a README/index that may live alongside the numbered ADRs.
      case "$base" in
        [0-9]*) printf 'adr' ;;
        *) : ;;
      esac
      ;;
    */docs/architecture/*.md | docs/architecture/*.md)
      case "$base" in
        current-state.md) : ;; # cartographer map — different structure
        *) printf 'architecture' ;;
      esac
      ;;
    *) : ;;
  esac
}

# Echo the expected sections for a type, one per line as "Label::regex".
# The regex is matched case-insensitively against the whole file (extended regex).
expected_sections_for_type() {
  local type="$1"
  case "$type" in
    prd)
      printf '%s\n' \
        'Problem statement::problem statement' \
        'Goals::goals' \
        'Non-goals::non-?goals?' \
        'Success metrics::success metrics?' \
        'Non-functional requirements::non-?functional|nfr'
      ;;
    adr)
      printf '%s\n' \
        'Status::status' \
        'Context::context' \
        'Decision Drivers::decision drivers' \
        'Considered Options::considered options' \
        'Decision Outcome::decision outcome' \
        'Consequences::consequences'
      ;;
    architecture)
      printf '%s\n' \
        'Non-functional requirements::non-?functional|nfr' \
        'Trade-offs / alternatives::trade-?offs?|alternatives'
      ;;
    *) : ;;
  esac
}

# Echo the labels of sections missing from the file (one per line; empty if complete).
missing_sections() {
  local file="$1" type="$2"
  local entry label regex
  while IFS= read -r entry; do
    [[ -z "$entry" ]] && continue
    label="${entry%%::*}"
    regex="${entry#*::}"
    if ! grep -qiE -- "$regex" "$file"; then
      printf '%s\n' "$label"
    fi
  done < <(expected_sections_for_type "$type")
}

# Validate one file. Prints a hook JSON object with a systemMessage warning to stdout
# when sections are missing; prints nothing when the file is complete or not an
# artifact. Always returns 0 — this hook is advisory, never blocking.
validate_artifact() {
  local file="$1"
  [[ -f "$file" ]] || return 0

  local type
  type=$(artifact_type_for_path "$file")
  [[ -n "$type" ]] || return 0

  local missing
  missing=$(missing_sections "$file" "$type")
  [[ -n "$missing" ]] || return 0

  local list
  list=$(printf '%s' "$missing" | paste -sd ',' - | sed 's/,/, /g')
  printf '{"systemMessage":"ae-architect: %s (%s) is missing expected section(s): %s"}\n' \
    "$file" "$type" "$list"
  return 0
}

# Extract .tool_input.file_path from a PostToolUse JSON event using whatever JSON
# tool is available. Echoes the path or nothing.
extract_file_path() {
  local json="$1"
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$json" | jq -r '.tool_input.file_path // empty'
  elif command -v python3 >/dev/null 2>&1; then
    printf '%s' "$json" | python3 -c \
      'import json,sys; print(json.load(sys.stdin).get("tool_input",{}).get("file_path",""))'
  else
    die "validate-artifact.sh: need jq or python3 to parse the hook event"
  fi
}

main() {
  if [[ "${1:-}" == "--file" ]]; then
    [[ -n "${2:-}" ]] || die "usage: validate-artifact.sh --file <path>"
    validate_artifact "$2"
    return 0
  fi

  local input file
  input=$(cat)
  [[ -n "$input" ]] || return 0
  file=$(extract_file_path "$input")
  [[ -n "$file" ]] || return 0
  validate_artifact "$file"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
