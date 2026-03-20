#!/bin/bash
# claude-mood: neon/cyberpunk theme

input=$(cat)

RESET="\033[0m"
BOLD="\033[1m"
GRAY="\033[90m"
NEON_CYAN="\033[96m"
NEON_GREEN="\033[92m"
NEON_YELLOW="\033[93m"
NEON_RED="\033[91m"
BRIGHT_PINK="\033[95m"
BLUE="\033[34m"
HONEY="\033[38;5;222m"
ORANGE="\033[38;5;208m"
CORAL="\033[38;5;203m"

# jq required
if ! command -v jq &>/dev/null; then
  echo "claude-mood: install jq"
  exit 0
fi

# Titles — rotate per session
TITLES=("keep it hot" "so wired" "let's rip")
SESSION_ID=$(echo "$input" | jq -r '.session_id // "x"')
IDX=$(echo "$SESSION_ID" | cksum | cut -d' ' -f1)
TITLE=${TITLES[$(( IDX % ${#TITLES[@]} ))]}

MODEL=$(echo "$input" | jq -r '.model.display_name // "Claude"')
CWD=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')
CTX_PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
LINES_ADDED=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
LINES_REMOVED=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')

BRANCH=""
if [ -n "$CWD" ]; then
  BRANCH=$(git -C "$CWD" rev-parse --abbrev-ref HEAD 2>/dev/null)
fi

build_bar() {
  local pct=$1
  local filled=$(( pct * 8 / 100 ))
  local empty=$(( 8 - filled ))
  local bar=""
  for ((i=0; i<filled; i++)); do bar+="▓"; done
  for ((i=0; i<empty; i++)); do bar+="░"; done
  echo "$bar"
}

CTX_BAR=$(build_bar "$CTX_PCT")

if [ "$CTX_PCT" -ge 80 ] 2>/dev/null; then
  CTX_COLOR=$CORAL
elif [ "$CTX_PCT" -ge 50 ] 2>/dev/null; then
  CTX_COLOR=$ORANGE
else
  CTX_COLOR=$NEON_CYAN
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
LINE+="  ${CORAL}😎 ${MODEL}${RESET}"
LINE+="  ${CTX_COLOR}👉 ${CTX_BAR} ${CTX_PCT}%${RESET}"
LINE+="  ${BRIGHT_PINK}⚡ \$${COST_FMT}${RESET}"
LINE+="  ${NEON_GREEN}💫 ${DURATION_FMT}${RESET}"

if [ "$LINES_ADDED" -gt 0 ] || [ "$LINES_REMOVED" -gt 0 ]; then
  LINE+="  ${NEON_GREEN}+${LINES_ADDED}${RESET}/${NEON_RED}-${LINES_REMOVED}${RESET}"
fi

echo -e "$LINE"
if [ -n "$BRANCH" ]; then
  echo -e "${GRAY}→ ${BRANCH}${RESET}"
fi
