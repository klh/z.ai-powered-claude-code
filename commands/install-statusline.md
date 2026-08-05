---
description: Install the claude-code-statusline status bar into ~/.claude
allowed-tools: Bash(mkdir:*), Bash(cp:*), Bash(chmod:*), Bash(jq:*), Bash(mv:*), Bash(ls:*), Bash(test:*)
---

Install the **claude-code-statusline** status line for the current user. The script is bundled with this plugin at `${CLAUDE_PLUGIN_ROOT}/claude/statusLine.sh`.

Do all of the following (use `jq` for the JSON merge; preserve every existing key in the user's settings):

1. Ensure `~/.claude` exists.
2. Copy `${CLAUDE_PLUGIN_ROOT}/claude/statusLine.sh` to `~/.claude/statusLine.sh` and make it executable.
3. Confirm `jq` is installed (required). If not, stop and tell the user to install it (`brew install jq` / `apt install jq`).
4. Back up `~/.claude/settings.json` if it exists, then merge in the status line by setting `.statusLine` to `{"type":"command","command":"bash $HOME/.claude/statusLine.sh"}` (keep `$HOME` literal). If the file doesn't exist, create it with just that object.

When done, tell the user to **restart Claude Code** (or open a new session) and to set their terminal font to a **Nerd Font** (e.g. FiraCode Nerd Font Mono) so the icons render.
