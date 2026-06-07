#!/usr/bin/env node
/**
 * Pre-flight check for dd-web-full-test.
 * Detects framework, build tool, installed tools. Outputs JSON.
 * Usage: node scripts/preflight.mjs
 */
import { readFileSync, existsSync } from "node:fs";
import { execSync } from "node:child_process";
import { request } from "node:http";

const result = {
  framework: "vanilla",
  buildTool: "none",
  devServerPort: "3000",
  devServerRunning: false,
  tools: { playwright: null, vitest: null, jest: null, axe: false },
  componentLib: null,
  missingTools: [],
  runner: "node",
};

// ── Detect framework & build tool ──────────────────────────────────

if (existsSync("package.json")) {
  try {
    const pkg = JSON.parse(readFileSync("package.json", "utf-8"));
    const deps = { ...pkg.dependencies, ...pkg.devDependencies };

    if (deps.next) { result.framework = "next.js"; result.buildTool = "next.js"; result.componentLib = "@testing-library/react"; }
    else if (deps.react) { result.framework = "react"; result.componentLib = "@testing-library/react"; }
    else if (deps.vue) { result.framework = String(deps.vue).startsWith("2") ? "vue2" : "vue3"; result.componentLib = "@testing-library/vue"; }
    else if (deps["@angular/core"]) { result.framework = "angular"; result.componentLib = "@angular/core/testing"; }
    else if (deps.svelte) { result.framework = "svelte"; result.componentLib = "@testing-library/svelte"; }
    else if (deps["solid-js"]) { result.framework = "solidjs"; result.componentLib = "@solidjs/testing-library"; }

    if (existsSync("vite.config.js") || existsSync("vite.config.ts")) result.buildTool = "vite";
    else if (existsSync("angular.json")) result.buildTool = "angular-cli";
    else if (existsSync("svelte.config.js")) result.buildTool = "sveltekit";
    else if (deps["react-scripts"]) result.buildTool = "create-react-app";

    const scripts = pkg.scripts || {};
    const devCmd = scripts.dev || scripts.start || "";
    const portMatch = devCmd.match(/(?:--port|-p)\s+(\d+)/);
    if (portMatch) result.devServerPort = portMatch[1];
  } catch { /* ignore parse errors */ }
}

// ── Check tools ────────────────────────────────────────────────────

function getVersion(cmd) {
  try {
    return execSync(cmd, { timeout: 5000, stdio: ["ignore", "pipe", "ignore"] })
      .toString().trim().split("\n").pop();
  } catch { return null; }
}

result.tools.playwright = getVersion("node_modules/.bin/playwright --version") || getVersion("playwright --version");
result.tools.vitest = getVersion("node_modules/.bin/vitest --version") || getVersion("vitest --version");
result.tools.jest = getVersion("node_modules/.bin/jest --version") || getVersion("jest --version");
result.tools.axe = existsSync("node_modules/@axe-core/playwright");

// Dev server check — sync, blocks max 2s. Sets devServerRunning to true if reachable.
try {
  await new Promise((resolve) => {
    const req = request(
      { hostname: "localhost", port: parseInt(result.devServerPort), path: "/", method: "HEAD", timeout: 2000 },
      (res) => { result.devServerRunning = true; res.resume(); resolve(); }
    );
    req.on("error", () => resolve());
    req.on("timeout", () => { req.destroy(); resolve(); });
    req.end();
    setTimeout(() => { req.destroy(); resolve(); }, 2000);
  });
} catch { /* offline */ }

// Missing
if (!result.tools.playwright) result.missingTools.push("@playwright/test");
if (!result.tools.vitest && !result.tools.jest) result.missingTools.push("vitest");
if (!result.tools.axe) result.missingTools.push("@axe-core/playwright");

console.log(JSON.stringify(result, null, 2));
