---
name: dd-webapp-full-test
description: |
  Comprehensive web app testing across 6 dimensions: functional, visual regression,
  accessibility, security, compatibility, and performance. Framework-agnostic patterns
  using Playwright + Vitest. Portable across Claude Code, Codex, Cursor, Hermes.
tags: [testing, e2e, visual, a11y, security, performance, playwright, vitest, portable]
triggers:
  - "test my app thoroughly"
  - "run all 6 test dimensions"
  - "comprehensive test"
  - "full test suite"
  - "visual regression test"
  - "screenshot regression"
  - "accessibility audit"
  - "a11y scan"
  - "security scan"
  - "performance audit"
  - "bundle analysis"
---

# DD WebApp Full Test Suite

A comprehensive, 6-dimension testing framework for web applications. Runs on any coding agent — Claude Code, Codex, Cursor, Hermes, Copilot — with zero agent-specific tool calls.

## What You Get

| Step | Output |
|------|--------|
| 1. Discovery | Agent explores your app, identifies routes, components, selectors |
| 2. Test Generation | 6 test spec files written to `e2e/`, ready to run |
| 3. Execution | All dimensions run in order: functional → visual → a11y → security → compatibility → performance |
| 4. Report | `TEST-REPORT.md` at project root with pass/fail, issues found, and recommendations |
| 5. Cleanup | Temporary artifacts removed; test scripts and report kept |

**After running**: tell the agent *"test my app"* and get a complete audit with actionable fixes in one file.

## Platform Compatibility

| Dimension | Claude Code | Codex/Cursor | Hermes | Copilot |
|-----------|:-----------:|:------------:|:------:|:-------:|
| Functional (E2E) | ✅ | ✅ | ✅ | ✅ |
| Functional (Unit) | ✅ | ✅ | ✅ | ✅ |
| Visual Regression | ✅ | ✅ | ✅ | ✅ |
| Accessibility (a11y) | ✅ | ✅ | ✅ | ✅ |
| Security (input checks) | ✅ | ✅ | ✅ | ✅ |
| Security (XSS payloads) | ⚠️ * | ⚠️ * | ✅ | ⚠️ * |
| Compatibility | ✅ | ✅ | ✅ | ✅ |
| Performance (CWV) | ✅ | ✅ | ✅ | ✅ |
| Performance (Bundle) | ✅ | ✅ | ✅ | ✅ |

> ⚠️ **Content filter note**: Some LLM providers (Kimi, Moonshot, certain enterprise gateways) may flag security testing content. If you get a "high risk" or "content policy" rejection, the agent will automatically skip the XSS payload injection tests and note it in the report. All other dimensions run normally.

## Prerequisites

| What | Check | Install |
|------|-------|---------|
| Playwright | `npx playwright --version` | `npm install -D @playwright/test && npx playwright install chromium` |
| Vitest (unit/component) | `npx vitest --version` | `npm install -D vitest @testing-library/react @testing-library/jest-dom jsdom` |
| axe-core (a11y) | check package.json | `npm install -D @axe-core/playwright` |
| Dev server running | `curl localhost:<port>` | Start per project README/CLAUDE.md |
| Backend (if needed) | `curl localhost:<port>/health` | Start backend service |

## Quick Start

1. **Gather context**: Read the project's `CLAUDE.md`, `AGENTS.md`, or `README.md`. Identify: dev server command, port number, auth method, key routes, component tree, API endpoints.
2. **Explore UI**: Navigate key pages, inspect rendered DOM, identify selectors and ARIA roles.
3. **Write tests**: One spec file per dimension, using patterns below.
4. **Run dimensions in order**: functional → visual → a11y → security → compatibility → performance.
5. **Report**: Generate `TEST-REPORT.md` at project root with full findings.

## How Different Agents Use This Skill

| Agent | Discovery | How to load |
|-------|-----------|-------------|
| **Claude Code** | Place in `.claude/skills/` or reference from `CLAUDE.md` | Claude reads skill files automatically when referenced |
| **Codex / Cursor** | Reference from `AGENTS.md` → delegating to `CLAUDE.md` | Reads project instructions on session start |
| **Hermes** | Place in `~/.hermes/skills/` | Auto-triggered by matching keywords in user messages |
| **GitHub Copilot** | Reference in `.github/copilot-instructions.md` | Reads on chat session start |

This file itself is pure Markdown + code patterns — no YAML frontmatter is strictly required (the `---` block is metadata for Hermes, safely ignored by other agents).

## Dimension Overview

| # | Dimension | Primary Tool | Key Files |
|---|-----------|-------------|-----------|
| 1 | Functional | Vitest + RTL + Playwright | `*.test.ts`, `*.spec.ts` |
| 2 | Visual | `toHaveScreenshot()` | `e2e/visual.spec.ts` |
| 3 | A11y | axe-core + keyboard nav | `e2e/a11y.spec.ts` |
| 4 | Security | Input validation + header checks | `e2e/security.spec.ts` |
| 5 | Compatibility | Multi-browser + network throttle | `e2e/compat.spec.ts` |
| 6 | Performance | Performance API + bundle analysis | `e2e/perf.spec.ts` |

---

## Dimension 1: Functional Testing

See `references/functional-checklist.md` for the per-scenario checklist.

### 1.0 Gather Project Context

Before writing any test, collect:
- **Routes**: What pages exist? Which require auth? Any redirects?
- **Auth mechanism**: Email/password? OAuth? Phone code? Session cookie name?
- **Component tree**: What are the main components? What props do they take?
- **API endpoints**: List all backend endpoints used by the frontend.
- **State management**: Zustand? Redux? Context? What stores exist?
- **Selector map**: Key element selectors for buttons, inputs, dialogs (from DOM inspection).

### 1.1 Unit Tests (Vitest)

Test pure functions in isolation. No DOM, no browser.

```ts
import { describe, it, expect } from "vitest";

describe("formatRelativeTime", () => {
  it("returns 'just now' for < 1 minute", () => {
    expect(formatRelativeTime(Date.now() - 30_000)).toBe("just now");
  });
  it("returns formatted date for > 24 hours", () => {
    expect(formatRelativeTime(Date.now() - 2 * 86400_000)).toMatch(/\d{4}-\d{2}-\d{2}/);
  });
  it("returns empty string for invalid input", () => {
    expect(formatRelativeTime(NaN)).toBe("");
  });
});
```

Common targets: time formatting, ID generation, text transforms, data validation, alias/language mapping, URL extraction, token estimation.

### 1.2 Component Tests (RTL + Vitest)

Isolate one component. Mock dependencies and context providers.

```ts
import { render, screen } from "@testing-library/react";

describe("MessageBubble", () => {
  it("renders user message right-aligned", () => {
    render(<MessageBubble role="user" content="hello" />);
    expect(screen.getByText("hello")).toBeInTheDocument();
  });

  it("renders code block with syntax highlighting", async () => {
    render(<MessageBubble role="assistant" content="```ts\nconst x = 1\n```" />);
    await screen.findByText("const x = 1", {}, { timeout: 5000 });
    expect(screen.getByText("ts")).toBeInTheDocument();
  });
});
```

Key components to test: message bubbles, sidebar/chat list items, search dialog, settings/account panels, error states, loading skeletons.

### 1.3 Integration / E2E (Playwright)

Full user flows through the running application.

**Shared auth pattern (serial mode)** — prevents rate-limiting on repeated login:

```ts
import { test, expect, type Page } from "@playwright/test";

test.describe("authenticated flows", () => {
  test.describe.configure({ mode: "serial" });

  let page: Page;

  test.beforeAll(async ({ browser }) => {
    const ctx = await browser.newContext();
    page = await ctx.newPage();
    // Perform login once — adapt to your auth method
    await page.goto("/login");
    await page.getByLabel("Email").fill("test@example.com");
    await page.getByLabel("Password").fill("password");
    await page.getByRole("button", { name: /sign in/i }).click();
    await page.waitForURL("**/chat");
  });

  test("send message", async () => {
    await page.goto("/chat");
    // ... test logic reusing authed `page`
  });

  test("delete conversation", async () => {
    // `page` still has auth cookies
  });
});
```

**Selector discovery** (agent-agnostic approach):
- Navigate to the page and wait for `networkidle`
- Use `page.content()` or browser DOM inspector to identify elements
- Prefer `getByRole()`, `getByLabel()`, `getByPlaceholder()` over CSS selectors
- Take screenshots to visually verify the rendered state matches expectations

**Common pitfalls across UI frameworks:**
- `getByText("...")` can match sidebar titles, page headings, AND message content simultaneously — scope with `page.locator("main").getByText(...)` or use `.first()`
- UI component libraries (Radix, Shadcn, Headless UI) often hide native `<select>/<option>` elements — use `page.locator('option[value="1"]')`
- Context menus may use inline `<input>` elements (not `window.prompt()`) — look for `textbox` role in the DOM
- Register `page.on("dialog", callback)` BEFORE the action that triggers the dialog

### 1.4 API Contract Tests

Verify API responses match expected shapes using the authenticated browser context:

```ts
test("GET /api/items returns correct shape", async () => {
  const result = await page.evaluate(async () => {
    const res = await fetch("/api/items?limit=5", { credentials: "include" });
    return { status: res.status, body: await res.json() };
  });
  expect(result.status).toBe(200);
  expect(Array.isArray(result.body)).toBe(true);
  for (const item of result.body) {
    expect(item).toHaveProperty("id");
    expect(item).toHaveProperty("title");
  }
});
```

Test all CRUD endpoints: list, get by ID, create, update, delete. Verify 200/201 for success, 400/401/404 for expected errors.

---

## Dimension 2: Visual Regression

See `references/visual-checklist.md` for the 24-screenshot matrix.

### 2.0 Gather Project Context

- **Theme support**: Does the app have dark mode? How is it toggled (`.dark` class, data attribute)?
- **Responsive breakpoints**: What are the app's breakpoints? (mobile ~375px, tablet ~768px, desktop ~1440px)
- **Dynamic content**: Are there timestamps, random IDs, animations that need masking?
- **Key visual states**: List all pages, modals, toasts, and edge cases to capture.

### Pattern

```ts
test("chat page baseline", async ({ page }) => {
  await page.goto("/chat");
  await page.waitForLoadState("networkidle");

  // Freeze CSS animations
  await page.evaluate(() =>
    document.querySelectorAll("*").forEach(el => {
      (el as HTMLElement).style.animation = "none";
    })
  );

  await expect(page).toHaveScreenshot("chat-normal.png", {
    fullPage: true,
    maxDiffPixelRatio: 0.01, // 1% tolerance
  });
});
```

### Workflow

1. **Generate baselines**: `npx playwright test e2e/visual.spec.ts --update-snapshots`
2. **Compare**: `npx playwright test e2e/visual.spec.ts`
3. **Review diffs**: each failure produces `actual.png`, `expected.png`, and `diff.png` in `test-results/`

### Screenshot Checklist (see references/visual-checklist.md for full list)

| Category | States to capture |
|----------|-------------------|
| Core pages | Normal state, empty state, error state, loading state |
| Content types | Code blocks, long text, mixed languages, tables, lists |
| UI components | Dialogs, dropdowns, toasts, hover states |
| Dark mode | Every core page in dark theme |
| Responsive | 375px, 768px, 1440px — focus on layout shifts |

---

## Dimension 3: Accessibility

### 3.0 Gather Project Context

- **Page routes**: List all public and authenticated pages.
- **Interactive elements**: Modals, dropdowns, tooltips, tab panels.
- **Form elements**: Which inputs, selects, and buttons exist? Do they have `<label>` elements?
- **Keyboard expectations**: Expected Tab order through the page.

### Keyboard Navigation

```ts
test("dialog: open → focus trapped → Esc closes → focus returns", async ({ page }) => {
  await page.getByRole("button", { name: /search/i }).click();
  await expect(page.locator(":focus")).toHaveAttribute("placeholder", /search/i);
  await page.keyboard.press("Escape");
  await expect(page.getByRole("dialog")).not.toBeVisible();
  // Focus should return to the trigger button
});
```

Check: Tab order on key pages, focus trap inside modals/dialogs, focus return on close, arrow key navigation in lists, Enter to activate.

### axe-core Automated Scan

```ts
import AxeBuilder from "@axe-core/playwright";

test("no critical a11y violations", async ({ page }) => {
  await page.goto("/");
  await page.waitForLoadState("networkidle");

  const results = await new AxeBuilder({ page })
    .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa"])
    .analyze();

  const critical = results.violations.filter(
    v => v.impact === "critical" || v.impact === "serious"
  );
  expect(critical).toEqual([]);
});
```

---

## Dimension 4: Security

See `references/security-payloads.md` for test vectors.

> **Provider note**: The payload list in `references/security-payloads.md` contains common test strings that some LLM providers may flag. If your agent's underlying model rejects requests when loading this file, skip the payload injection tests and proceed with the header checks and input validation tests below. Note the skip in TEST-REPORT.md.

### 4.0 Gather Project Context

- **Input vectors**: Chat input, search fields, URL parameters, form fields, file uploads.
- **Output vectors**: Where does user-supplied or AI-generated content appear in the DOM?
- **Auth tokens**: How are they stored? `httpOnly` cookie? `localStorage`?
- **API surface**: List all endpoints. Which return user-specific data?
- **Headers**: Check for CSP, HSTS, X-Content-Type-Options, X-Frame-Options.

### HTML Output Safety

Inject content via the app's normal input mechanism and verify it appears as visible text without executing:

```ts
test("user input rendered as text, never executed", async ({ page }) => {
  const testStrings = [
    '<b>bold text</b>',
    '<img src=x onerror=console.log(1)>',
    '<svg onload=console.log(1)>',
  ];

  let unexpectedDialog = false;
  page.on("dialog", async (dialog) => {
    unexpectedDialog = true;
    await dialog.dismiss();
  });

  for (const str of testStrings) {
    await page.getByPlaceholder(/message/i).fill(str);
    await page.getByRole("button", { name: /send/i }).click();
    await expect(page.getByText(str, { exact: false })).toBeVisible();
  }

  expect(unexpectedDialog).toBe(false);
});
```

### Input Validation

- Empty or whitespace-only → send button is disabled
- Very long input (100k chars) → app doesn't crash; may truncate or show error
- Special characters (null bytes, zero-width spaces) → handled gracefully

### Sensitive Information

- Error responses must not leak stack traces, internal file paths, or database details.
- API list endpoints must only return data belonging to the authenticated user.
- No hardcoded secrets, tokens, or internal URLs in client-side code.

### Additional Payloads

For teams with unrestricted model access, `references/security-payloads.md` contains 50+ additional test strings covering HTML injection, event handlers, URL schemes, encoding variants, and markdown injection. Load this file only if your provider allows it.

---

## Dimension 5: Compatibility

### 5.0 Gather Project Context

- **Browser targets**: Which browsers are supported? Check `browserslist` in package.json.
- **Network assumptions**: Is the app expected to work offline? On slow connections?
- **Language/script support**: Does the app handle multi-language content (RTL scripts, non-Latin fonts like Tibetan, Arabic, CJK)?

### Multi-Browser Configuration

```ts
// playwright.config.ts
projects: [
  { name: "chromium", use: { ...devices["Desktop Chrome"], channel: "chrome" } },
  { name: "firefox",  use: { ...devices["Desktop Firefox"] } },
  { name: "safari",   use: { ...devices["Desktop Safari"] } },
]
```

### Network Conditions

```ts
test("offline — shows error instead of crashing", async ({ page, context }) => {
  await page.goto("/");
  await context.setOffline(true);
  await page.getByRole("button", { name: /send/i }).click();
  await expect(page.getByText(/network|offline|connection/i)).toBeVisible();
});

test("slow 3G — streaming still works", async ({ page }) => {
  const cdp = await page.context().newCDPSession(page);
  await cdp.send("Network.emulateNetworkConditions", {
    offline: false,
    downloadThroughput: (500 * 1024) / 8, // 500 Kbps
    uploadThroughput: (500 * 1024) / 8,
    latency: 400,
  });
  // Test SSE/streaming under slow network
});
```

### Multi-Language Rendering

For apps supporting non-Latin scripts, verify font rendering via `getComputedStyle`:

```ts
test("non-Latin script renders with correct font", async ({ page }) => {
  await page.goto("/");
  const text = "བོད་སྐད།"; // Tibetan example
  await page.getByPlaceholder(/message/i).fill(text);
  await page.getByRole("button", { name: /send/i }).click();
  await expect(page.getByText(text)).toBeVisible();

  const fontFamily = await page.locator(`text=${text}`).evaluate(
    el => getComputedStyle(el).fontFamily
  );
  expect(fontFamily).toMatch(/Tibetan|Noto Sans/i);
});
```

---

## Dimension 6: Performance

See `references/perf-metrics.md` for metric definitions and thresholds.

### 6.0 Gather Project Context

- **Build tool**: Next.js, Vite, CRA, or other? Determines where build output lives.
- **Bundle location**: `.next/static/chunks/` (Next.js), `dist/assets/` (Vite), `build/static/js/` (CRA).
- **API endpoints to measure**: List the most critical/frequent API calls.
- **SSE/streaming**: Does the app use Server-Sent Events or WebSockets?

### Page Load (Core Web Vitals)

```ts
async function measurePageLoad(page: Page, url: string) {
  await page.goto("about:blank");
  await page.evaluate(() => performance.clearResourceTimings());
  const start = Date.now();
  await page.goto(url, { waitUntil: "networkidle" });
  const tti = Date.now() - start;

  const m = await page.evaluate(() => {
    const nav = performance.getEntriesByType("navigation")[0] as PerformanceNavigationTiming;
    const paint = performance.getEntriesByType("paint");
    const fcp = paint.find((e: any) => e.name === "first-contentful-paint");
    let lcp = -1;
    try {
      const e = performance.getEntriesByType("largest-contentful-paint");
      if (e.length) lcp = e[e.length - 1].startTime;
    } catch {}
    const resources = performance.getEntriesByType("resource") as PerformanceResourceTiming[];
    return {
      fcp: fcp ? fcp.startTime : -1, lcp,
      dcl: nav ? nav.domContentLoadedEventEnd - nav.startTime : -1,
      load: nav ? nav.loadEventEnd - nav.startTime : -1,
      resources: resources.length,
      bytes: resources.reduce((s: number, r: any) => s + (r.transferSize || 0), 0),
      heap: (performance as any).memory?.usedJSHeapSize || 0,
    };
  });
  return { url, tti, ...m };
}
```

**Thresholds**: Dev mode — FCP < 5s, TTI < 20s. Production — FCP < 2s, TTI < 5s.

### Bundle Analysis

Walk the build output directory, rank by size, flag anything > 500KB:

```ts
import { readdirSync, statSync } from "fs";
import { join, relative } from "path";

function analyzeBundle(buildDir: string) {
  const files: { name: string; size: number }[] = [];
  function walk(dir: string) {
    for (const entry of readdirSync(dir, { withFileTypes: true })) {
      const fp = join(dir, entry.name);
      if (entry.isDirectory()) walk(fp);
      else if (entry.name.endsWith(".js")) files.push({
        name: relative(buildDir, fp),
        size: statSync(fp).size,
      });
    }
  }
  walk(buildDir);
  files.sort((a, b) => b.size - a.size);
  const total = files.reduce((s, f) => s + f.size, 0);
  return { files: files.slice(0, 15), total, count: files.length };
}
```

### API Latency

```ts
async function measureApiLatency(page: Page, endpoint: string) {
  return page.evaluate(async (ep) => {
    const t0 = performance.now();
    const res = await fetch(ep, { credentials: "include" });
    return { status: res.status, ms: Math.round(performance.now() - t0) };
  }, endpoint);
}
// Warm once, then measure 3x, take average. Threshold: < 5s.
```

### Additional Metrics

- **CLS**: `new PerformanceObserver(list => { for (const e of list.getEntries()) { if (!(e as any).hadRecentInput) cls += (e as any).value } }).observe({ type: 'layout-shift', buffered: true })`
- **Long Tasks**: `PerformanceObserver` on type `"longtask"`, record durations.
- **Cache hit**: Compare `transferSize` on 1st vs 2nd visit (≈ 0 = fully cached).
- **SSE first-token**: `Date.now()` at EventSource open vs first `data` event.
- **JS Heap**: `performance.memory.usedJSHeapSize` after a full usage session.
- **Production build**: Build output differs significantly from dev — always run `npm run build` for accurate metrics.

---

## Test Report

**CRITICAL**: After ALL 6 dimensions complete, generate a comprehensive Markdown report at the project root: `TEST-REPORT.md`. Then tell the user: *"Testing complete. Full report: `TEST-REPORT.md` in the project root."*

### Report Template

Copy this entire template into `TEST-REPORT.md`, filling in `{{PLACEHOLDERS}}` with actual test results:

```markdown
# Test Report — {{PROJECT_NAME}}

**Date**: {{DATE}}
**Tested by**: AI Agent ({{AGENT_NAME}})
**Dimensions tested**: 6/6
**Overall status**: {{OVERALL_STATUS}} ({{PASSED}}/6 dimensions passing)

---

## Summary

| # | Dimension | Status | Tests Run | Passed | Failed | Key Finding |
|---|-----------|--------|-----------|--------|--------|-------------|
| 1 | Functional | {{D1_STATUS}} | {{D1_TOTAL}} | {{D1_PASSED}} | {{D1_FAILED}} | {{D1_KEY}} |
| 2 | Visual | {{D2_STATUS}} | {{D2_TOTAL}} | {{D2_PASSED}} | {{D2_FAILED}} | {{D2_KEY}} |
| 3 | Accessibility | {{D3_STATUS}} | {{D3_TOTAL}} | {{D3_PASSED}} | {{D3_FAILED}} | {{D3_KEY}} |
| 4 | Security | {{D4_STATUS}} | {{D4_TOTAL}} | {{D4_PASSED}} | {{D4_FAILED}} | {{D4_KEY}} |
| 5 | Compatibility | {{D5_STATUS}} | {{D5_TOTAL}} | {{D5_PASSED}} | {{D5_FAILED}} | {{D5_KEY}} |
| 6 | Performance | {{D6_STATUS}} | {{D6_TOTAL}} | {{D6_PASSED}} | {{D6_FAILED}} | {{D6_KEY}} |

---

## Dimension 1: Functional Testing

### Unit Tests
{{UNIT_TEST_TABLE_OR_SUMMARY}}

### Component Tests
{{COMPONENT_TEST_TABLE_OR_SUMMARY}}

### E2E Flows
| Test | Status | Notes |
|------|--------|-------|
| Auth: unauthenticated redirect | {{PASS/FAIL}} | {{NOTES}} |
| Auth: valid login | {{PASS/FAIL}} | {{NOTES}} |
| Auth: invalid credentials | {{PASS/FAIL}} | {{NOTES}} |
| Create new item | {{PASS/FAIL}} | {{NOTES}} |
| Send message | {{PASS/FAIL}} | {{NOTES}} |
| Multi-turn conversation | {{PASS/FAIL}} | {{NOTES}} |
| Long message (3000+ chars) | {{PASS/FAIL}} | {{NOTES}} |
| Rename item | {{PASS/FAIL}} | {{NOTES}} |
| Delete item | {{PASS/FAIL}} | {{NOTES}} |
| Search/filter | {{PASS/FAIL}} | {{NOTES}} |
| Sidebar/panel toggle | {{PASS/FAIL}} | {{NOTES}} |

### API Contract
| Endpoint | Status | Response Shape | Notes |
|----------|--------|----------------|-------|
| {{GET /api/items}} | {{PASS/FAIL}} | {{CORRECT/MISSING}} | {{NOTES}} |
| {{GET /api/items/:id}} | {{PASS/FAIL}} | {{CORRECT/MISSING}} | {{NOTES}} |
| {{POST /api/items}} | {{PASS/FAIL}} | {{CORRECT/MISSING}} | {{NOTES}} |
| {{PUT /api/items/:id}} | {{PASS/FAIL}} | {{CORRECT/MISSING}} | {{NOTES}} |
| {{DELETE /api/items/:id}} | {{PASS/FAIL}} | {{CORRECT/MISSING}} | {{NOTES}} |

### Issues Found
{{LIST_EACH_ISSUE_WITH_SEVERITY_AND_REPRO_STEPS}}

---

## Dimension 2: Visual Regression

### Screenshots Captured
| # | Screenshot | Status | Diff |
|---|-----------|--------|------|
{{FOR_EACH_SCREENSHOT}}

### Issues Found
| Screenshot | Issue | Severity | Recommendation |
|-----------|-------|----------|----------------|
{{LIST_ISSUES}}

---

## Dimension 3: Accessibility

### axe-core Scan Results
| Page | Violations (Critical) | Violations (Serious) | Violations (Moderate) |
|------|----------------------|---------------------|----------------------|
{{FOR_EACH_PAGE}}

### Violation Details
{{FOR_EACH_VIOLATION}}
- **Rule**: {{RULE_ID}}
- **Impact**: {{IMPACT}}
- **Element**: {{ELEMENT}}
- **Description**: {{DESCRIPTION}}
- **Fix**: {{RECOMMENDATION}}
{{END_FOR}}

### Keyboard Navigation
| Scenario | Status | Notes |
|----------|--------|-------|
| Tab order on main page | {{PASS/FAIL}} | {{NOTES}} |
| Dialog focus trap | {{PASS/FAIL}} | {{NOTES}} |
| Dialog Esc close | {{PASS/FAIL}} | {{NOTES}} |
| Focus return on close | {{PASS/FAIL}} | {{NOTES}} |

---

## Dimension 4: Security

### HTML Output Safety
| Test String | Rendered as Text? | Dialog Triggered? | Notes |
|-------------|-------------------|-------------------|-------|
{{FOR_EACH_TEST_STRING}}

### Headers Check
| Header | Present? | Value | Recommendation |
|--------|----------|-------|----------------|
| Content-Security-Policy | {{YES/NO}} | {{VALUE}} | {{REC}} |
| X-Content-Type-Options | {{YES/NO}} | {{VALUE}} | {{REC}} |
| Strict-Transport-Security | {{YES/NO}} | {{VALUE}} | {{REC}} |
| X-Frame-Options | {{YES/NO}} | {{VALUE}} | {{REC}} |
| Cache-Control | {{YES/NO}} | {{VALUE}} | {{REC}} |

### Input Validation
| Test | Result | Notes |
|------|--------|-------|
| Empty input → send disabled | {{PASS/FAIL}} | {{NOTES}} |
| Whitespace-only → disabled | {{PASS/FAIL}} | {{NOTES}} |
| 100k char input → no crash | {{PASS/FAIL}} | {{NOTES}} |

### Issues Found
{{LIST_ISSUES_WITH_SEVERITY}}

---

## Dimension 5: Compatibility

### Browser Results
| Browser | Tests Run | Passed | Failed | Key Issues |
|---------|-----------|--------|--------|------------|
| Chromium | {{N}} | {{N}} | {{N}} | {{ISSUES}} |
| Firefox | {{N}} | {{N}} | {{N}} | {{ISSUES}} |
| Safari | {{N}} | {{N}} | {{N}} | {{ISSUES}} |

### Network Conditions
| Scenario | Status | Notes |
|----------|--------|-------|
| Offline — error shown | {{PASS/FAIL}} | {{NOTES}} |
| Slow 3G — streaming OK | {{PASS/FAIL}} | {{NOTES}} |

### Multi-Language Rendering
| Script | Font Applied Correctly? | Notes |
|--------|------------------------|-------|
{{FOR_EACH_SCRIPT}}

---

## Dimension 6: Performance

### Core Web Vitals
| Page | FCP | LCP | DCL | TTI | Resources | Transfer | Heap |
|------|-----|-----|-----|-----|-----------|----------|------|
{{FOR_EACH_PAGE}}

### Bundle Analysis
Total chunks: {{N}}
Total size: {{SIZE}}
Largest chunk: {{NAME}} ({{SIZE}})

| # | Chunk | Size |
|---|-------|------|
{{TOP_15}}

**Warnings**: {{LIST_CHUNKS_OVER_500KB}}

### API Latency (avg of 3)
| Endpoint | Duration | Status |
|----------|----------|--------|
{{FOR_EACH_ENDPOINT}}

### Additional Metrics
| Metric | Value | Threshold | Status |
|--------|-------|-----------|--------|
| CLS | {{VALUE}} | < 0.1 | {{PASS/FAIL}} |
| Long Tasks | {{COUNT}} | 0 | {{PASS/FAIL}} |
| Cache hit (2nd visit) | {{YES/NO}} | transfer ≈ 0 | {{PASS/FAIL}} |
| SSE first-token | {{MS}}ms | < 2s | {{PASS/FAIL}} |

---

## Console Errors

{{LIST_ALL_CONSOLE_ERRORS_OR_"No console errors detected across all tests."}}

---

## Recommendations

### Critical (fix before release)
{{LIST_CRITICAL_ISSUES}}

### Should Fix (fix before next feature)
{{LIST_SHOULD_FIX_ISSUES}}

### Nice to Have (improve when possible)
{{LIST_NICE_TO_HAVE}}

---

## Test Artifacts

- Test scripts: `e2e/*.spec.ts`
- Screenshot baselines: `e2e/screenshots/`
- Screenshot diffs: `test-results/*/diff.png`
- Playwright report: `playwright-report/` (if generated)

## Cleanup

```bash
# Remove run artifacts (keep test scripts)
rm -rf test-results/ playwright-report/
```
```

### Post-Test Instructions

After writing `TEST-REPORT.md`:

1. **Tell the user**: "Testing complete. Full report generated at `TEST-REPORT.md` in the project root."
2. **Summarize top 3 findings** in the chat response so they don't need to open the file immediately.
3. **Offer cleanup**: "Run cleanup commands to remove test artifacts? (test-results/, screenshots/)"
4. **Do NOT delete** `TEST-REPORT.md` during cleanup — it's the permanent record.

## File Structure Created

```
e2e/
  functional.spec.ts       # E2E integration
  visual.spec.ts           # toHaveScreenshot baselines
  a11y.spec.ts             # axe-core audit
  security.spec.ts         # input validation + header checks
  compat.spec.ts           # multi-browser + network
  perf.spec.ts             # page load + bundle + API
  screenshots/             # visual regression baselines
src/__tests__/
  *.test.ts                # Vitest unit tests
  *.component.test.tsx     # RTL component tests (React)
```

## Pitfalls

- **Serial auth**: Login ONCE in `beforeAll`, reuse the `page` object. Each `test()` call with `loginViaPhoneCode()` or equivalent will rate-limit.
- **Text matching ambiguity**: `getByText("message")` in chat apps matches sidebar title, page heading, AND message content simultaneously. Scope with `page.locator("main")` or `.first()`.
- **Dev ≠ Production bundle**: Dev server bundles everything into fewer, larger chunks. Run `npm run build` for real numbers.
- **UI library `<select>` overrides**: Radix, Shadcn, and Headless UI hide native `<option>` elements. Use CSS `option[value="1"]` instead of `getByRole("option")`.
- **Screenshot flakiness**: Freeze CSS animations, mock `Date.now()`, mask random IDs. Use `maxDiffPixelRatio: 0.01` tolerance.
- **axe-core timing**: Wait for `networkidle` before scanning — dynamic content won't be in the initial DOM.
- **Dialog handlers**: Register `page.on("dialog", callback)` BEFORE the click that triggers it.
- **CDP network emulation**: `Network.emulateNetworkConditions` is Chromium-only. For Firefox/Safari, use `page.route()` with artificial delays.
- **Content filters**: Some LLM providers (Kimi, Moonshot, enterprise gateways) may reject security testing content as "high risk". The skill handles this gracefully — skips payload injection tests, notes it in the report, and continues with all other dimensions.

## Cleanup

After tests complete, remove generated artifacts:

```bash
# Playwright run artifacts
rm -rf test-results/

# Visual baselines (if not committing to repo)
rm -rf e2e/screenshots/*.png

# Playwright HTML report
rm -rf playwright-report/

# Kill temporary test servers
lsof -ti :<PORT> | xargs kill -9 2>/dev/null
```

**Keep vs delete:**

| Keep | Delete |
|------|--------|
| `e2e/*.spec.ts` (test scripts) | `test-results/` (run artifacts) |
| `e2e/screenshots/` (if committed baselines) | `e2e/screenshots/*.png` (if ad-hoc) |
| `playwright.config.ts` | `playwright-report/` |
| `TEST-REPORT.md` | Temporary mock servers and test apps |
| Skill files and references | |
