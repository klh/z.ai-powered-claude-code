#!/usr/bin/env bash
# claude-code-statusline installer — copies the script and merges the statusLine setting.
# Usage:  curl -fsSL https://raw.githubusercontent.com/klh/claude-code-statusline/main/install.sh | bash
set -uo pipefail

RAW="${STATUSLINE_RAW:-https://raw.githubusercontent.com/klh/claude-code-statusline/main}"
CLAUDE_DIR="${HOME}/.claude"
SETTINGS="${CLAUDE_DIR}/settings.json"
TARGET="${CLAUDE_DIR}/statusLine.sh"
CMD='bash $HOME/.claude/statusLine.sh'

printf '▶ installing claude-code-statusline\n'

if ! command -v jq >/dev/null 2>&1; then
  printf '✗ jq is required (the status line parses JSON with it).\n  macOS: brew install jq · Debian/Ubuntu: sudo apt install jq\n'; exit 1
fi
command -v curl >/dev/null 2>&1 || { printf '✗ curl is required.\n'; exit 1; }

mkdir -p "${CLAUDE_DIR}"

printf '  downloading statusLine.sh -> %s\n' "${TARGET}"
curl -fsSL "${RAW}/claude/statusLine.sh" -o "${TARGET}" || { printf '✗ failed to download statusLine.sh\n'; exit 1; }
chmod +x "${TARGET}"

printf '  configuring %s\n' "${SETTINGS}"
if [ ! -e "${SETTINGS}" ] || [ ! -s "${SETTINGS}" ]; then
  printf '{"statusLine":{"type":"command","command":"%s"}}\n' "${CMD}" > "${SETTINGS}"
else
  cp "${SETTINGS}" "${SETTINGS}.bak"
  tmp="$(mktemp)"
  if jq --arg c "${CMD}" '.statusLine = {"type":"command","command":$c}' "${SETTINGS}" > "${tmp}" 2>/dev/null; then
    mv "${tmp}" "${SETTINGS}"
    printf '  (old settings backed up to %s.bak)\n' "${SETTINGS}"
  else
    rm -f "${tmp}"
    printf '✗ %s is not valid JSON — left unchanged (see .bak). Fix and re-run.\n' "${SETTINGS}"; exit 1
  fi
fi

printf '✓ done. Restart Claude Code (or open a new session) to see the status line.\n'
printf '  Tip: use a Nerd Font (e.g. FiraCode Nerd Font Mono) for the icons.\n'
