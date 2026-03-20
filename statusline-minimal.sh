#!/bin/bash
# claude-mood: default/minimal theme

input=$(cat)

RESET="\033[0m"
DIM="\033[2m"
GRAY="\033[90m"
CYAN="\033[36m"
BRIGHT_BLUE="\033[94m"
RED="\033[31m"
ORANGE="\033[38;5;208m"

# jq required
if ! command -v jq &>/dev/null; then
  echo "claude-mood: install jq"
  exit 0
fi

# Titles — rotate per session
TITLES=("clear and quiet" "steady as i go" "moving with intent")
SESSION_ID=$(echo "$input" | jq -r '.session_id // "x"')
IDX=$(echo "$SESSION_ID" | cksum | cut -d' ' -f1)
TITLE=${TITLES[$(( IDX % ${#TITLES[@]} ))]}

MODEL=$(echo "$input" | jq -r '.model.display_name // "Claude"')
CWD=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')
CTX_PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)

BRANCH=""
if [ -n "$CWD" ]; then
  BRANCH=$(git -C "$CWD" rev-parse --abbrev-ref HEAD 2>/dev/null)
fi

build_bar() {
  local pct=$1
  local filled=$(( pct * 8 / 100 ))
  local empty=$(( 8 - filled ))
  local bar=""
  for ((i=0; i<filled; i++)); do bar+="█"; done
  for ((i=0; i<empty; i++)); do bar+="░"; done
  echo "$bar"
}

CTX_BAR=$(build_bar "$CTX_PCT")

if [ "$CTX_PCT" -ge 80 ] 2>/dev/null; then
  CTX_COLOR=$RED
elif [ "$CTX_PCT" -ge 50 ] 2>/dev/null; then
  CTX_COLOR=$ORANGE
else
  CTX_COLOR=$CYAN
fi

COST_FMT=$(printf "%.3f" "$COST" 2>/dev/null || echo "0.000")

DURATION_SEC=$(( DURATION_MS / 1000 ))
if [ "$DURATION_SEC" -ge 3600 ]; then
  DURATION_FMT="$(( DURATION_SEC / 3600 ))h$(( (DURATION_SEC % 3600) / 60 ))m"
elif [ "$DURATION_SEC" -ge 60 ]; then
  DURATION_FMT="$(( DURATION_SEC / 60 ))m"
else
  DURATION_FMT="${DURATION_SEC}s"
fi

LINE="${GRAY}♥︎ ${TITLE}${RESET}"
LINE+="  ${BRIGHT_BLUE}• ${MODEL}${RESET}"
LINE+="  ${CTX_COLOR}• ${CTX_BAR} ${CTX_PCT}%${RESET}"
LINE+="  ${DIM}• \$${COST_FMT}${RESET}"
LINE+="  ${DIM}• ${DURATION_FMT}${RESET}"

echo -e "$LINE"
if [ -n "$BRANCH" ]; then
  echo -e "${GRAY}→ ${BRANCH}${RESET}"
fi
