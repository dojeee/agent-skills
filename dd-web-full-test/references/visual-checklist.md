# Visual Regression Screenshot Checklist

24 screenshot scenarios covering core states, themes, and viewports.

## Core Pages

| # | Screenshot | State | What to Check |
|---|-----------|-------|---------------|
| 1 | normal-state | Main page with typical content | Element positioning, spacing, colors |
| 2 | code-block | Content with syntax-highlighted code | Code colors, line numbers, background |
| 3 | mixed-scripts | Content with multiple writing systems | Font fallback, line height, no tofu |
| 4 | long-content | Very long text or code block | Text wrap, no horizontal overflow, scrollbar |
| 5 | rich-content | Tables, lists, quotes, links | All markdown elements render correctly |
| 6 | loading-state | Page or component loading | Skeleton/spinner visible, no layout jump |
| 7 | error-state | API error or network failure visible | Error toast/banner, not blank page |
| 8 | empty-state | No data yet (new user, empty list) | Empty state message and call-to-action |

## Navigation / Sidebar

| # | Screenshot | State |
|---|-----------|-------|
| 9 | list-normal | Items visible with titles |
| 10 | item-hover | Context menu or actions appear on hover |
| 11 | search-open | Search/filter dialog visible with results |
| 12 | search-empty | Search with no matching results |

## Settings / Account Dialogs

| # | Screenshot | State |
|---|-----------|-------|
| 13 | settings-tab-1 | First/default tab open |
| 14 | settings-tab-2 | Second tab open |
| 15 | settings-tab-3 | Third tab open |
| 16 | dropdown-open | Select/dropdown menu expanded |

## Dark Mode

Repeat core page screenshots with dark theme applied:

| # | Screenshot |
|---|-----------|
| 17 | dark-normal-state |
| 18 | dark-code-block |
| 19 | dark-mixed-scripts |
| 20 | dark-sidebar |

## Responsive Viewports

Focus: layout shifts, sidebar behavior, content readability.

| # | Viewport | Screenshot |
|---|----------|-----------|
| 21 | 375×812 (mobile) | Main page at mobile width |
| 22 | 375×812 (mobile) | Sidebar/navigation at mobile (overlay vs collapse) |
| 23 | 768×1024 (tablet) | Main page at tablet width |
| 24 | 1440×900 (desktop) | Main page at full desktop width |

## Usage

```ts
import { test, expect } from "@playwright/test";

test("visual baseline — main page", async ({ page }) => {
  await page.goto("/");
  await page.waitForLoadState("networkidle");
  // Freeze animations
  await page.evaluate(() =>
    document.querySelectorAll("*").forEach(el => {
      (el as HTMLElement).style.animation = "none";
    })
  );
  await expect(page).toHaveScreenshot("main-normal.png", {
    fullPage: true,
    maxDiffPixelRatio: 0.01,
  });
});
```

## Tips

- **Animations**: Freeze CSS animations before capture: `el.style.animation = 'none'`
- **Timestamps**: Mock `Date.now()` to a fixed value, or mask with `style: 'color: transparent'`
- **Random IDs**: Use Playwright's `mask` option: `mask: [page.locator('[data-testid="item-id"]')]`
- **Baselines**: Run `--update-snapshots` first from a known-good state
- **Diff review**: Each failure produces `actual.png`, `expected.png`, `diff.png` in `test-results/`
