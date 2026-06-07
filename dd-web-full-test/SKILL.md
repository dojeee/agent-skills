---
name: dd-web-full-test
description: Comprehensive report-only web application QA across functional behavior, visual regression, accessibility, security hygiene, browser compatibility, and performance. Use when the user asks to test a web app thoroughly, run a full QA audit, create an end-to-end test report, check visual screenshots, audit a11y, verify security headers/input safety, measure performance, or run Playwright/Vitest-based web app tests without fixing application code.
---

# DD Web Full Test

Run a six-dimension, report-only QA audit for a web application. The skill may add test files and a final report, but it must not fix product code.

## Hard Rules

1. Do not modify business code.
   - Allowed: create or update test files under `e2e/`, `tests/`, or the project's established test directories.
   - Allowed: write `TEST-REPORT.html`.
   - Not allowed: change application logic, components, routes, styles, build config, package scripts, or production source files.
2. Ask before installing anything.
   - Show the exact package manager command and affected dimensions.
   - If the user declines, skip the affected dimensions and record the skip.
3. Treat results as evidence.
   - Use `PASS`, `FAIL`, or `SKIP`.
   - Include actual output, screenshots, console errors, response bodies, metrics, or repro steps for every failure.
4. Continue through failures.
   - Do not stop the audit because one assertion fails.
   - Record the failure, continue with the next scenario, then summarize at the end.

## Execution Flow

Follow these phases in order. Each phase has a clear output; do not skip ahead unless the user explicitly narrows the request to one dimension.

### Phase 0. Scope The Audit

Output: audit scope and constraints.

Confirm or infer:

- Target app root and tested URL.
- Whether the audit is full six-dimension coverage or a narrowed dimension.
- Whether credentials, seed data, or test accounts are required.
- Whether this is report-only. Default to report-only and do not fix product code.

If credentials or destructive test data are required, stop and ask the user before proceeding.

### Phase 1. Run Preflight

Output: framework/build/tooling JSON.

Run the bundled preflight from the target app root. Try the scripts in this order and use the first valid JSON result:

```bash
node path/to/dd-web-full-test/scripts/preflight.mjs
python3 path/to/dd-web-full-test/scripts/preflight.py
bash path/to/dd-web-full-test/scripts/preflight.sh
```

The JSON reports framework, build tool, detected port, server reachability, installed testing tools, and missing dependencies.

If the app server is not running, inspect project instructions and start it with the existing dev command. If the command or port is ambiguous, ask the user before proceeding.

### Phase 2. Resolve Dependency Gate

Output: final runnable dimensions and skipped dimensions.

If `missingTools` is not empty, stop and ask whether to install them. Prefer the project's package manager:

| Lockfile | Command shape |
|----------|---------------|
| `pnpm-lock.yaml` | `pnpm add -D <tools>` |
| `yarn.lock` | `yarn add -D <tools>` |
| `bun.lock` / `bun.lockb` | `bun add -d <tools>` |
| otherwise | `npm install -D <tools>` |

If `@playwright/test` is installed for the first time, also ask before running browser installation commands such as `npx playwright install chromium`.

If the user declines installation, immediately mark affected dimensions as `SKIP` and continue with dimensions that can run.

### Phase 3. Build Coverage Plan

Output: dimension-by-dimension plan.

Create a short plan showing which dimensions will run and which will be skipped:

1. Functional: unit, component, E2E, API contract
2. Visual: screenshot regression and responsive states
3. Accessibility: axe-core and keyboard navigation
4. Security: output escaping, input validation, headers, leak checks
5. Compatibility: browser projects, network conditions, language/script rendering
6. Performance: page metrics, bundle size, API latency, runtime signals

Only ask for confirmation if the plan creates files, installs tools, starts services, or needs credentials. If the user already requested a full audit and no risky action is needed, proceed.

The plan must include:

- Dimensions to run or skip, with reasons.
- Target routes and flows.
- Test files to create.
- Expected commands to execute.
- Artifacts to preserve.

### Phase 4. Discover Test Surface

Output: selector map and scenario inventory.

Before writing tests, gather:

- Routes, auth requirements, redirects, and primary user flows.
- Main components, forms, dialogs, menus, tables, and error/loading states.
- API endpoints used by the frontend.
- Supported browsers and responsive breakpoints.
- Dynamic visual content that must be frozen, mocked, or masked.

Prefer rendered DOM and accessible selectors. Use `getByRole`, `getByLabel`, and `getByPlaceholder` before brittle CSS selectors.

### Phase 5. Create Or Adapt Test Files

Output: test files ready to run.

Create focused test files only under test-owned paths such as `e2e/`, `tests/`, or the project's established test directories.

Do not add broad abstractions unless the same setup is reused across multiple dimensions. Prefer local helpers inside the test file for one-off setup.

Use these default file names unless the project already has a clearer convention:

| Dimension | Default file |
|-----------|--------------|
| Functional | `e2e/functional.spec.ts` |
| Visual | `e2e/visual.spec.ts` |
| Accessibility | `e2e/a11y.spec.ts` |
| Security | `e2e/security.spec.ts` |
| Compatibility | `e2e/compat.spec.ts` |
| Performance | `e2e/perf.spec.ts` |

### Phase 6. Execute Dimension By Dimension

Output: pass/fail/skip counts and evidence for each dimension.

Run dimensions in order. After each dimension, record pass/fail/skip counts and key evidence.

#### Functional

Use Vitest or Jest for pure utilities and component tests when the project already supports them. Use Playwright for user flows and API contracts.

Load `references/functional-checklist.md` when choosing scenarios.

Framework mapping:

| Framework | Component tool |
|-----------|----------------|
| React / Next.js | `@testing-library/react` |
| Vue 3 | `@testing-library/vue` or `@vue/test-utils` |
| Vue 2 | `@vue/test-utils` v1 |
| Angular | `@angular/core/testing` + `TestBed` |
| Svelte | `@testing-library/svelte` |
| SolidJS | `@solidjs/testing-library` |
| Vanilla HTML/JS | Skip component tests; use E2E and utility tests only |

For authenticated flows, log in once in serial setup and reuse the authenticated context to avoid rate limits.

#### Visual

Use Playwright `toHaveScreenshot()` after waiting for the app to settle. Freeze animations and mask timestamps, random IDs, cursors, and live regions.

Load `references/visual-checklist.md` for the screenshot matrix.

Use at least mobile, tablet, and desktop viewports when the app is responsive. Capture dark mode only if the app supports it.

#### Accessibility

Use `@axe-core/playwright` when installed, plus manual keyboard checks:

- Tab order reaches all interactive controls.
- Dialog focus is trapped while open.
- Escape closes dismissible overlays.
- Focus returns to the trigger.
- Form controls have accessible names.

If axe is not installed and the user declined installation, run keyboard and accessible-selector checks, then mark automated axe scans as `SKIP`.

#### Security

Check only application-owned surfaces and do not attack third-party services.

Run:

- Output safety: user-controlled text renders as text and does not execute.
- Input validation: empty, whitespace-only, very long, control characters.
- Headers: CSP, HSTS, X-Content-Type-Options, X-Frame-Options or frame-ancestors, Cache-Control where relevant.
- Leak checks: no stack traces, local paths, database errors, server versions, or secrets in client bundles or API errors.

Load `data/security-payloads.md` only when running payload injection tests. If the model/provider blocks that file, skip payload injection and continue with headers, validation, and leak checks.

#### Compatibility

Use the project's Playwright browser projects if present. Otherwise run Chromium and note missing Firefox/WebKit coverage unless installation is approved.

Check:

- Mobile and desktop layout.
- Offline or failed-network behavior where relevant.
- Slow-network behavior for streaming or critical API flows.
- Non-Latin and RTL text rendering only when the product handles user-entered text.

#### Performance

Load `references/perf-metrics.md` for definitions and thresholds.

Measure:

- FCP, LCP when available, DOMContentLoaded, networkidle wall-clock, transfer size, resource count.
- Bundle output after a production build if the project has a build command.
- Important API latency, warmed then measured multiple times.
- CLS, long tasks, cache behavior, heap, and first-token delay when relevant.

Clearly distinguish dev-mode findings from production-build findings.

### Phase 7. Write The HTML Report

Output: `TEST-REPORT.html`.

Create `TEST-REPORT.html` at the target app root. Use `references/report-template.html` as the structure, but remove irrelevant sections instead of leaving placeholders.

The report must include:

- Project name, date, tested URL, framework/build tool, and dimensions run.
- Summary table with `PASS`, `FAIL`, and `SKIP` counts.
- Evidence for each failed scenario.
- Screenshot paths or Playwright report paths where applicable.
- Repro steps for user-visible failures.
- Recommendations grouped by severity.
- Skipped dimensions and the exact reason.

HTML requirements:

- Produce one self-contained HTML file with inline CSS.
- Use semantic sections, tables, and status badges for scanability.
- Escape all test output and user-controlled strings before inserting them into HTML.
- Link local artifacts with relative paths when possible.
- Keep the report readable in a browser without a dev server.

After writing the report, reply with the path and the top three findings. Offer cleanup for transient artifacts such as `test-results/` and `playwright-report/`, but never delete `TEST-REPORT.html`.

### Phase 8. Handoff

Output: concise chat summary.

End with:

- Link or path to `TEST-REPORT.html`.
- Dimensions run, failed, and skipped.
- Top three findings with severity.
- Test artifacts left in the repo.
- Cleanup recommendation for transient artifacts only.

## Resource Map

- `scripts/preflight.mjs`: primary stack and tool detector.
- `scripts/preflight.py`: Python fallback.
- `scripts/preflight.sh`: shell fallback.
- `references/functional-checklist.md`: scenario ideas for functional coverage.
- `references/visual-checklist.md`: screenshot matrix and visual stability tips.
- `references/perf-metrics.md`: metrics, thresholds, and collection snippets.
- `references/report-template.html`: final HTML report structure.
- `data/security-payloads.md`: optional payload vectors for authorized security testing.

## Common Pitfalls

- Do not let `npx` install missing tools during detection; ask the user first.
- Wait for `networkidle` before DOM inspection or screenshots on dynamic apps.
- Scope text selectors; repeated labels often appear in nav, headings, and content.
- Register dialog handlers before actions that might trigger dialogs.
- Do not compare screenshot baselines until the first known-good baseline exists.
- Do not interpret dev bundle size as production bundle size.
- Note Chromium-only CDP network emulation when Firefox/WebKit cannot run the same test.
