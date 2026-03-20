#!/bin/bash
# claude-mood: cutesy theme
# Reads Claude Code session JSON from stdin

input=$(cat)

# Colors
RESET="\033[0m"
DIM="\033[2m"
GRAY="\033[90m"
BLUSH="\033[38;5;225m"
SKY_BLUE="\033[38;5;117m"
BUTTER="\033[38;5;229m"
HONEY="\033[38;5;222m"
SALMON="\033[38;5;210m"
PISTACHIO="\033[38;5;193m"
ROSE="\033[38;5;211m"

# jq required
if ! command -v jq &>/dev/null; then
  echo "claude-mood: install jq for full experience"
  exit 0
fi

# Titles — rotate per session
TITLES=("the path is kind" "growing gently" "all is soft")
SESSION_ID=$(echo "$input" | jq -r '.session_id // "x"')
IDX=$(echo "$SESSION_ID" | cksum | cut -d' ' -f1)
TITLE=${TITLES[$(( IDX % ${#TITLES[@]} ))]}

MODEL=$(echo "$input" | jq -r '.model.display_name // "Claude"')
CWD=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')
CTX_PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
VIM_MODE=$(echo "$input" | jq -r '.vim.mode // ""')
LINES_ADDED=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
LINES_REMOVED=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')

# Git branch
BRANCH=""
if [ -n "$CWD" ]; then
  BRANCH=$(git -C "$CWD" rev-parse --abbrev-ref HEAD 2>/dev/null)
fi

# Context progress bar (8 blocks)
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

# Context color: butter → honey → salmon
if [ "$CTX_PCT" -ge 80 ] 2>/dev/null; then
  CTX_COLOR=$SALMON
elif [ "$CTX_PCT" -ge 50 ] 2>/dev/null; then
  CTX_COLOR=$HONEY
else
  CTX_COLOR=$BLUSH
fi

# Format cost
COST_FMT=$(printf "%.3f" "$COST" 2>/dev/null || echo "0.000")

# Format duration
DURATION_SEC=$(( DURATION_MS / 1000 ))
if [ "$DURATION_SEC" -ge 3600 ]; then
  DURATION_FMT="$(( DURATION_SEC / 3600 ))h$(( (DURATION_SEC % 3600) / 60 ))m"
elif [ "$DURATION_SEC" -ge 60 ]; then
  DURATION_FMT="$(( DURATION_SEC / 60 ))m"
else
  DURATION_FMT="${DURATION_SEC}s"
fi

# Vim mode badge
VIM_BADGE=""
if [ "$VIM_MODE" = "NORMAL" ]; then
  VIM_BADGE=" ${BOLD}[N]${RESET}"
elif [ "$VIM_MODE" = "INSERT" ]; then
  VIM_BADGE=" ${BOLD}[I]${RESET}"
fi

# Single line: mood + branch + model + context bar + cost + duration
LINE="${GRAY}♥︎ ${TITLE}${RESET}${VIM_BADGE}"
LINE+="  ${SKY_BLUE}🦋 ${MODEL}${RESET}"
LINE+="  ${CTX_COLOR}🌸 ${CTX_BAR} ${CTX_PCT}%${RESET}"
LINE+="  ${PISTACHIO}🍀 \$${COST_FMT}${RESET}"
LINE+="  ${BUTTER}🌙 ${DURATION_FMT}${RESET}"

# Lines diff (only show if nonzero)
if [ "$LINES_ADDED" -gt 0 ] || [ "$LINES_REMOVED" -gt 0 ]; then
  LINE+="  ${PISTACHIO}+${LINES_ADDED}${RESET}${DIM}/${RESET}${ROSE}-${LINES_REMOVED}${RESET}"
fi

echo -e "$LINE"
if [ -n "$BRANCH" ]; then
  echo -e "${GRAY}→ ${BRANCH}${RESET}"
fi
