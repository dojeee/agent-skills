#!/usr/bin/env python3
"""Pre-flight check for dd-webapp-full-test. Outputs JSON."""
import json, os, subprocess, sys

PKG = "package.json"
result = {
    "framework": "unknown", "buildTool": "unknown",
    "devServerPort": "3000", "devServerRunning": False,
    "tools": {"playwright": None, "vitest": None, "jest": None, "axe": False},
    "componentLib": None, "missingTools": [],
    "runner": "python"
}

# ── Detect framework & build tool ──────────────────────────────────

if os.path.exists(PKG):
    try:
        pkg = json.load(open(PKG)); deps = {**pkg.get("dependencies",{}), **pkg.get("devDependencies",{})}
        if "next" in deps: result["framework"], result["buildTool"], result["componentLib"] = "next.js", "next.js", "@testing-library/react"
        elif "react" in deps: result["framework"], result["componentLib"] = "react", "@testing-library/react"
        elif "vue" in deps: result["framework"], result["componentLib"] = ("vue3" if str(deps["vue"]).startswith(("3","^3")) else "vue2"), "@testing-library/vue"
        elif "@angular/core" in deps: result["framework"], result["componentLib"] = "angular", "@angular/core/testing"
        elif "svelte" in deps: result["framework"], result["componentLib"] = "svelte", "@testing-library/svelte"
        elif "solid-js" in deps: result["framework"], result["componentLib"] = "solidjs", "@solidjs/testing-library"
        if os.path.exists("vite.config.js") or os.path.exists("vite.config.ts"): result["buildTool"] = "vite"
        elif os.path.exists("angular.json"): result["buildTool"] = "angular-cli"
        elif os.path.exists("svelte.config.js"): result["buildTool"] = "sveltekit"
        elif "react-scripts" in deps: result["buildTool"] = "create-react-app"
        scripts = pkg.get("scripts",{}); dc = scripts.get("dev","") or scripts.get("start","")
        import re; m = re.search(r'(?:--port|-p)\s+(\d+)', dc)
        if m: result["devServerPort"] = m.group(1)
    except: pass
else:
    result["framework"], result["buildTool"] = "vanilla", "none"

# ── Check tools ────────────────────────────────────────────────────

def ver(cmd):
    try: return subprocess.check_output(cmd, shell=True, stderr=subprocess.STDOUT, timeout=5).decode().strip().split("\n")[-1]
    except: return None

result["tools"]["playwright"] = ver("npx playwright --version 2>/dev/null || playwright --version 2>/dev/null")
result["tools"]["vitest"] = ver("npx vitest --version 2>/dev/null")
result["tools"]["jest"] = ver("npx jest --version 2>/dev/null")
result["tools"]["axe"] = os.path.exists("node_modules/@axe-core/playwright")

try:
    import urllib.request; urllib.request.urlopen(f"http://localhost:{result['devServerPort']}", timeout=2); result["devServerRunning"] = True
except: pass

if not result["tools"]["playwright"]: result["missingTools"].append("@playwright/test")
if not result["tools"]["vitest"] and not result["tools"]["jest"]: result["missingTools"].append("vitest")
if not result["tools"]["axe"]: result["missingTools"].append("@axe-core/playwright")

print(json.dumps(result, indent=2))
