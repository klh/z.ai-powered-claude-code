#!/bin/bash
# Claude Code Status Line — optimized + enriched (bash 3.2-compatible).
# Single jq pass; tier-colored model; git branch/dirty/ahead-behind;
# context-window % with mini bar; compact mode on narrow terminals.

RESET='\033[0m'
BOLD_WHITE='\033[1;37m'; BOLD_YELLOW='\033[1;33m'; BOLD_BLUE='\033[1;34m'
BOLD_GREEN='\033[1;32m'; BOLD_RED='\033[1;31m'
GREEN='\033[0;32m'; YELLOW='\033[0;33m'; RED='\033[0;31m'; PURPLE='\033[0;35m'

input=$(cat)
IFS=$'\t' read -r MODEL_ID MODEL_NAME CURRENT_DIR LINES_ADDED LINES_REMOVED API_DUR_MS DUR_MS COST PCT CTX_SIZE <<< "$(
  jq -r '[
    (.model.id // ""),
    (.model.display_name // "unknown"),
    (.workspace.current_dir // .cwd // ""),
    (.cost.total_lines_added // 0),
    (.cost.total_lines_removed // 0),
    (.cost.total_api_duration_ms // 0),
    (.cost.total_duration_ms // 0),
    (.cost.total_cost_usd // 0),
    (.context_window.used_percentage // 0),
    (.context_window.context_window_size // 0)
  ] | @tsv' <<< "$input"
)"

API_DUR=$(( ${API_DUR_MS:-0} / 1000 ))
DUR=$(( ${DUR_MS:-0} / 1000 ))
COST_FMT=$(printf '%.3f' "${COST:-0}")
PCT_INT=$(printf '%.0f' "${PCT:-0}")
CTX_SIZE=${CTX_SIZE:-0}
DIR_NAME="${CURRENT_DIR##*/}"; DIR_NAME="${DIR_NAME//\\/\\\\}"

case "$MODEL_ID" in
  *opus*|glm-5.2*)   MC=$BOLD_GREEN ;;
  *haiku*)           MC=$BOLD_YELLOW ;;
  *sonnet*|glm-5.1*) MC=$BOLD_BLUE ;;
  *)                 MC=$BOLD_WHITE ;;
esac
if [[ "$MODEL_ID" == claude-* ]]; then ICON="👾"; else ICON="👹"; fi

# git: branch + dirty + ahead/behind in ONE call, pure-bash parse
GIT_PART=""
if STATUS=$(git status -b --porcelain 2>/dev/null); then
  LINE1="${STATUS%%$'\n'*}"
  BRANCH="${LINE1#\#\# }"; BRANCH="${BRANCH%%...*}"; BRANCH="${BRANCH%% *}"
  if [[ "$BRANCH" == "HEAD" || -z "$BRANCH" ]]; then BRANCH="$(git rev-parse --short HEAD 2>/dev/null)"; fi
  AHEAD=""; BEHIND=""
  re_a='ahead ([0-9]+)';   re_b='behind ([0-9]+)'
  [[ "$LINE1" =~ $re_a ]] && AHEAD="${BASH_REMATCH[1]}"
  [[ "$LINE1" =~ $re_b ]] && BEHIND="${BASH_REMATCH[1]}"
  REST="${STATUS#*$'\n'}"
  DIRTY=""; [ "$REST" != "$STATUS" ] && [ -n "$REST" ] && DIRTY="${BOLD_RED}✱${RESET}"
  AB=""; [ -n "$AHEAD" ]  && AB+=" ${BOLD_GREEN}↑${AHEAD}${RESET}"
  [ -n "$BEHIND" ] && AB+=" ${BOLD_RED}↓${BEHIND}${RESET}"
  [ -n "$BRANCH" ] && GIT_PART=" |  ${BOLD_BLUE}${BRANCH}${RESET}${DIRTY}${AB}"
fi

if   ((PCT_INT >= 80)); then CC=$RED;    elif ((PCT_INT >= 50)); then CC=$YELLOW; else CC=$GREEN; fi
filled=$((PCT_INT / 10)); ((filled > 10)) && filled=10
bar=""; i=0
while ((i < filled)); do bar+="█"; ((i++)); done
while ((i < 10));     do bar+="░"; ((i++)); done
TAG=""; ((CTX_SIZE >= 1000000)) && TAG=" ∞"
CTX_PART=" |  ${CC}${bar}${RESET} ${CC}${PCT_INT}%${RESET}${TAG}"

COLS=${COLUMNS:-0}
DUR_PART=" |  ${GREEN}${API_DUR}${RESET}/${PURPLE}${DUR}${RESET}s"
COST_PART=" | ${GREEN}${COST_FMT}${RESET}"
((COLS > 0 && COLS < 110)) && { DUR_PART=""; COST_PART=""; }
((COLS > 0 && COLS < 80))  && CTX_PART=" |  ${CC}${PCT_INT}%${RESET}${TAG}"

OUTPUT="${RESET}${ICON} [ ${MC}${MODEL_NAME}${RESET} ]  ${BOLD_YELLOW}${DIR_NAME}${RESET}${GIT_PART}${CTX_PART}${DUR_PART}${COST_PART} ${ICON}"
printf '%b\n' "$OUTPUT"
