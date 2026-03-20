Switch the claude-mood statusline theme by updating settings.json directly.

Available themes: (1) cute, (2) punk, (3) minimal

The requested theme is: $ARGUMENTS

If $ARGUMENTS is empty or not one of the valid themes above, list the available themes instead and do not run any commands.

Otherwise, run this exact bash command to switch (replace THEME with the actual theme name):
```
jq '.statusLine.command = "bash \($ENV.HOME)/.claude/mood/statusline-THEME.sh"' "$HOME/.claude/settings.json" > /tmp/mood-settings.tmp && mv /tmp/mood-settings.tmp "$HOME/.claude/settings.json"
```

Then confirm with a single short sentence only — no taglines, no extra flavor. Examples:
- cute → "switched to cute ★"
- punk → "switched to punk ✶"
- minimal → "switched to minimal ◆"
