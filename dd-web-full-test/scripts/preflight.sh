#!/usr/bin/env bash
# Pre-flight check for dd-web-full-test. Outputs JSON.
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

[ -x "node_modules/.bin/playwright" ] && PW_VER=$(_run node_modules/.bin/playwright --version 2>/dev/null | tail -1)
[ -x "node_modules/.bin/vitest" ] && VT_VER=$(_run node_modules/.bin/vitest --version 2>/dev/null | tail -1)
[ -x "node_modules/.bin/jest" ] && JEST_VER=$(_run node_modules/.bin/jest --version 2>/dev/null | tail -1)
[ -z "$PW_VER" ] && command -v playwright >/dev/null 2>&1 && PW_VER=$(_run playwright --version 2>/dev/null | tail -1)
[ -z "$VT_VER" ] && command -v vitest >/dev/null 2>&1 && VT_VER=$(_run vitest --version 2>/dev/null | tail -1)
[ -z "$JEST_VER" ] && command -v jest >/dev/null 2>&1 && JEST_VER=$(_run jest --version 2>/dev/null | tail -1)
[ -d "node_modules/@axe-core/playwright" ] && AXE=true

# Dev server (2s timeout)
curl -s --max-time 2 -o /dev/null -w "%{http_code}" "http://localhost:$PORT" 2>/dev/null | grep -q "200\|301\|302\|304" && DEV_RUNNING=true

# ── Output JSON ──────────────────────────────────────────────────────

json_or_null() {
  if [ -n "$1" ]; then
    printf '"%s"' "$(printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g')"
  else
    printf 'null'
  fi
}

MISSING=""
add_missing() {
  if [ -z "$MISSING" ]; then
    MISSING="\"$1\""
  else
    MISSING="$MISSING, \"$1\""
  fi
}

[ -z "$PW_VER" ] && add_missing "@playwright/test"
[ -z "$VT_VER" ] && [ -z "$JEST_VER" ] && add_missing "vitest"
[ "$AXE" = false ] && add_missing "@axe-core/playwright"

cat <<JSONEOF
{
  "framework": "$FW",
  "buildTool": "$BT",
  "devServerPort": "$PORT",
  "devServerRunning": $DEV_RUNNING,
  "tools": {
    "playwright": $(json_or_null "$PW_VER"),
    "vitest": $(json_or_null "$VT_VER"),
    "jest": $(json_or_null "$JEST_VER"),
    "axe": $AXE
  },
  "componentLib": $(json_or_null "$CLIB"),
  "missingTools": [$MISSING],
  "runner": "shell"
}
JSONEOF
