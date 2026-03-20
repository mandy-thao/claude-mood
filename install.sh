#!/bin/bash
# claude-mood installer

set -e

REPO="https://raw.githubusercontent.com/YOUR_USERNAME/claude-mood/main"
MOOD_DIR="$HOME/.claude/mood"
COMMANDS_DIR="$HOME/.claude/commands"
SETTINGS="$HOME/.claude/settings.json"

echo "installing claude-mood..."

# check dependencies
if ! command -v jq &>/dev/null; then
  echo "error: jq is required. install with: brew install jq"
  exit 1
fi

# create directories
mkdir -p "$MOOD_DIR"
mkdir -p "$COMMANDS_DIR"

# download theme scripts
for theme in statusline-cute statusline-minimal statusline-punk; do
  curl -fsSL "$REPO/${theme}.sh" -o "$MOOD_DIR/${theme}.sh"
  chmod +x "$MOOD_DIR/${theme}.sh"
done

# download color preview script
curl -fsSL "$REPO/show-colors.sh" -o "$MOOD_DIR/show-colors.sh"
chmod +x "$MOOD_DIR/show-colors.sh"

# download /mood slash command
curl -fsSL "$REPO/mood.md" -o "$COMMANDS_DIR/mood.md"

# patch settings.json
if [ ! -f "$SETTINGS" ]; then
  echo '{}' > "$SETTINGS"
fi

jq --arg cmd "bash $MOOD_DIR/statusline-cute.sh" \
  '.statusLine = {"type": "command", "command": $cmd}' \
  "$SETTINGS" > /tmp/claude-mood-settings.tmp && mv /tmp/claude-mood-settings.tmp "$SETTINGS"

echo ""
echo "done! claude-mood is installed."
echo ""
echo "themes: cute (default) · punk · minimal"
echo "switch with /mood cute, /mood punk, /mood minimal"
echo "preview colors with: bash $MOOD_DIR/show-colors.sh"
