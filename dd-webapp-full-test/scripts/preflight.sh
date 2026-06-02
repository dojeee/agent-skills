#!/usr/bin/env bash
# Pre-flight check for dd-webapp-full-test. Outputs JSON.
# Usage: bash scripts/preflight.sh
# All npx calls have a 10s timeout to avoid hanging.

PKG="package.json"
FW="vanilla"
BT="none"
PORT="3000"
DEV_RUNNING=false
PW_VER=""
VT_VER=""
JEST_VER=""
AXE=false
CLIB=""

# ── Helper: run command with timeout (macOS doesn't have `timeout`) ──

_run() {
  if command -v timeout >/dev/null 2>&1; then
    timeout 10 "$@" 2>/dev/null
  elif command -v perl >/dev/null 2>&1; then
    perl -e 'alarm 10; exec @ARGV' "$@" 2>/dev/null
  else
    "$@" 2>/dev/null
  fi
}

# ── Detect framework ─────────────────────────────────────────────────

if [ -f "$PKG" ]; then
  grep -q '"next"' "$PKG" 2>/dev/null && { FW="next.js"; BT="next.js"; CLIB="@testing-library/react"; }
  grep -q '"react"' "$PKG" 2>/dev/null && [ "$FW" = "vanilla" ] && { FW="react"; CLIB="@testing-library/react"; }
  grep -q '"vue"' "$PKG" 2>/dev/null && { FW="vue3"; CLIB="@testing-library/vue"; }
  grep -q '"@angular/core"' "$PKG" 2>/dev/null && { FW="angular"; CLIB="@angular/core/testing"; }
  grep -q '"svelte"' "$PKG" 2>/dev/null && { FW="svelte"; CLIB="@testing-library/svelte"; }
  grep -q '"solid-js"' "$PKG" 2>/dev/null && { FW="solidjs"; CLIB="@solidjs/testing-library"; }

  [ -f "vite.config.js" ] || [ -f "vite.config.ts" ] && BT="vite"
  [ -f "angular.json" ] && BT="angular-cli"
  [ -f "svelte.config.js" ] && BT="sveltekit"
  grep -q '"react-scripts"' "$PKG" 2>/dev/null && BT="create-react-app"

  DC=$(grep -oE '"dev"[[:space:]]*:[[:space:]]*"[^"]*"' "$PKG" 2>/dev/null | head -1)
  PM=$(echo "$DC" | grep -oE '(--port|-p)[[:space:]]+[0-9]+' | awk '{print $2}')
  [ -n "$PM" ] && PORT="$PM"
fi

# ── Check tools (with timeout) ──────────────────────────────────────

command -v npx >/dev/null 2>&1 && {
  PW_VER=$(_run npx playwright --version 2>/dev/null | tail -1)
  VT_VER=$(_run npx vitest --version 2>/dev/null | tail -1)
  JEST_VER=$(_run npx jest --version 2>/dev/null | tail -1)
}
[ -z "$PW_VER" ] && command -v playwright >/dev/null 2>&1 && PW_VER=$(_run playwright --version 2>/dev/null | tail -1)
[ -d "node_modules/@axe-core/playwright" ] && AXE=true

# Dev server (2s timeout)
curl -s --max-time 2 -o /dev/null -w "%{http_code}" "http://localhost:$PORT" 2>/dev/null | grep -q "200\|301\|302\|304" && DEV_RUNNING=true

# ── Output JSON ──────────────────────────────────────────────────────

cat <<JSONEOF
{
  "framework": "$FW",
  "buildTool": "$BT",
  "devServerPort": "$PORT",
  "devServerRunning": $DEV_RUNNING,
  "tools": {
    "playwright": "${PW_VER:-null}",
    "vitest": "${VT_VER:-null}",
    "jest": "${JEST_VER:-null}",
    "axe": $AXE
  },
  "componentLib": "${CLIB:-null}",
  "missingTools": [
    $([ -z "$PW_VER" ] && echo '"@playwright/test",')
    $([ -z "$VT_VER" ] && [ -z "$JEST_VER" ] && echo '"vitest",')
    $([ "$AXE" = false ] && echo '"@axe-core/playwright"')
  ],
  "runner": "shell"
}
JSONEOF
