#!/bin/bash
# Claude Code Status Line — optimized (single jq pass).
# Called by Claude Code with JSON on stdin. Shows model, dir, git, +/−, duration, cost.

RESET='\033[0m'
BOLD_WHITE='\033[1;37m'; BOLD_YELLOW='\033[1;33m'; BOLD_BLUE='\033[1;34m'
BOLD_GREEN='\033[1;32m'; BOLD_RED='\033[1;31m'
GREEN='\033[0;32m'; PURPLE='\033[0;35m'

# Read stdin once, extract every field in a SINGLE jq call (tab-separated).
input=$(cat)
IFS=$'\t' read -r MODEL_ID MODEL_NAME CURRENT_DIR LINES_ADDED LINES_REMOVED API_DUR_MS DUR_MS COST <<< "$(
  jq -r '[
    (.model.id // ""),
    (.model.display_name // "unknown"),
    (.workspace.current_dir // .cwd // ""),
    (.cost.total_lines_added // 0),
    (.cost.total_lines_removed // 0),
    (.cost.total_api_duration_ms // 0),
    (.cost.total_duration_ms // 0),
    (.cost.total_cost_usd // 0)
  ] | @tsv' <<< "$input"
)"

# Null/empty-safe arithmetic (default 0 — a missing field can't break the line).
API_DUR=$(( ${API_DUR_MS:-0} / 1000 ))
DUR=$(( ${DUR_MS:-0} / 1000 ))
COST_FMT=$(printf '%.3f' "${COST:-0}")

# Dir basename, backslashes escaped.
DIR_NAME="${CURRENT_DIR##*/}"
DIR_NAME="${DIR_NAME//\\/\\\\}"

# Git branch — one call, errors suppressed.
BRANCH=$(git branch --show-current 2>/dev/null)
GIT_PART=""
[ -n "$BRANCH" ] && GIT_PART=" | 🌿 ${BOLD_BLUE}${BRANCH}${RESET}"

# Icon: claude-* -> 👾, anything else (GLM) -> 👹
if [[ "$MODEL_ID" == claude-* ]]; then ICON="👾"; else ICON="👹"; fi

OUTPUT="${RESET}${ICON} [ ${BOLD_WHITE}${MODEL_NAME}${RESET} ] 📁 ${BOLD_YELLOW}${DIR_NAME}${RESET}${GIT_PART} ${BOLD_GREEN}+${RESET}${LINES_ADDED} ${BOLD_RED}-${RESET}${LINES_REMOVED} | ⌚ ${GREEN}${API_DUR}${RESET}/${PURPLE}${DUR}${RESET}s | 💲${GREEN}${COST_FMT}${RESET} ${ICON}"
printf '%b\n' "$OUTPUT"
