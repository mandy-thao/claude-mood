# claude-mood

A statusline theme system for [Claude Code](https://claude.ai/code). Three themes, session-rotating titles, and a `/mood` command to switch between them.

![themes: minimal · cute · punk]

## themes

**cute** — soft pastels. rotating titles: *the path is kind · growing gently · all is soft*

**punk** — neon and loud. rotating titles: *keep it hot · so wired · let's rip*

**minimal** — clean and quiet. rotating titles: *clear and quiet · steady as i go · moving with intent*

## install

Requires [jq](https://stedolan.github.io/jq/): `brew install jq`

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/claude-mood/main/install.sh | bash
```

Restart Claude Code after installing.

## usage

```
/mood minimal
/mood cute
/mood punk
```

To preview all available colors in your terminal:
```bash
bash ~/.claude/mood/show-colors.sh
```

## customizing

All theme files live at `~/.claude/mood/`. Ask Claude to edit them — change colors, icons, titles, or anything else. The files are plain bash scripts.

## what's in the statusline

| element | description |
|---|---|
| `♥︎ title` | rotating session title |
| model | current Claude model |
| bar | context window usage |
| cost | session cost in USD |
| duration | session duration |
| `→ branch` | git branch (when in a repo) |
