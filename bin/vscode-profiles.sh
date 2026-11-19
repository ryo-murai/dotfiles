#!/usr/bin/env bash
set -euo pipefail

case "$(uname -s)" in
  MINGW* | MSYS*)
    # Windows Git Bash
    powershell.exe -NoProfile -Command \
      '(Get-Content "$env:APPDATA\Code\User\globalStorage\storage.json" -Raw | ConvertFrom-Json).userDataProfiles.name'
    ;;
  Linux*)
    # WSL
    if ! grep -qi microsoft /proc/sys/kernel/osrelease; then
      echo "Error: WSL is required." >&2
      exit 1
    fi

    jq -r '.userDataProfiles[]?.name' \
      "$HOME/.vscode-server/data/User/globalStorage/storage.json"
    ;;
  *)
    echo "Error: Unsupported platform: $(uname -s)" >&2
    exit 1
    ;;
esac

