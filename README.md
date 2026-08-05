# Claude Code Status Line

A rich, single-line status bar for [Claude Code](https://claude.com/claude-code). Shows the live model + reasoning effort, your location (repo + subdir), git state, lines changed, context-window usage, time, and cost — Nerd Font glyphs + Powerline arrows, tier-colored, with smart narrow-terminal compaction. Model-agnostic (works with Anthropic *or* z.ai/GLM models).

```
👾 [ GLM-5.2 (1M) · high ]  icomdev/tredebanken-v2/backend/src  branch✱↑2  +142 -37  ██░░░ 46%∞  45/120s  0.234 👹
```

| Segment | Info |
|---|---|
| `[ model · effort ]` | model display name (tier-colored) + reasoning effort (`.effort.level`), color-coded |
| `owner/repo/subdir` | pwd — repo identity + current subdirectory (or `~`-abbreviated pwd); truncated on narrow |
| `branch ✱ ↑N ↓N` | git branch, dirty marker, ahead/behind |
| `+N -N` | lines added/removed this session |
| `██░░░ NN%∞` | context-window usage (green <50 / yellow <80 / red ≥80; `∞` = 1M-context model) |
| `api/total s` | API time / total wall-clock |
| `0.234` | session cost (USD) |

## Requirements
- A **Nerd Font** in your terminal (e.g. `FiraCode Nerd Font Mono`) — for the icons + Powerline arrows.
- **jq** — parses Claude Code's status-line JSON.

## Install
1. Copy the script:
   ```bash
   cp claude/statusLine.sh ~/.claude/statusLine.sh && chmod +x ~/.claude/statusLine.sh
   ```
2. Merge this into `~/.claude/settings.json` (don't replace the file):
   ```json
   { "statusLine": { "type": "command", "command": "bash $HOME/.claude/statusLine.sh" } }
   ```
3. Restart Claude Code (or open a new session).

## Notes
- **Narrow terminals** (< 110 cols): drops duration/cost/context-bar and truncates branch + subpath.
- Single `jq` pass + one `git` call (~40 ms); bash-3.2-compatible (macOS system bash).
- Tweak colors/thresholds in `claude/statusLine.sh`.

---

Forked from [geoh/z.ai-powered-claude-code](https://github.com/geoh/z.ai-powered-claude-code); this fork keeps just the status line.
