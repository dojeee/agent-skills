# Functional Testing Checklist

## Unit Tests (Vitest)

### Time / Date Utilities
- [ ] `< 1 min → "just now"`
- [ ] `5 min → "5m ago"`
- [ ] `2 hours → "2h ago"`
- [ ] `> 24h → formatted date string`
- [ ] `Invalid input (NaN, null, undefined) → safe fallback`

### ID / Text Transforms
- [ ] ID generation produces unique values
- [ ] String truncation at boundary (empty, exact length, over)
- [ ] Slug/safe-name generation from arbitrary input
- [ ] Whitespace normalization and trim

### Data Validation
- [ ] Email format validation (valid, invalid, edge cases)
- [ ] URL parsing and domain extraction
- [ ] Numeric range validation (min, max, NaN)
- [ ] Required field checks

### Language / Locale
- [ ] Language/script detection functions
- [ ] Character/word/token counting for mixed scripts
- [ ] Text direction detection (LTR vs RTL)

---

## Component Tests (RTL + Vitest)

### Message / Content Bubbles
- [ ] User message: correct alignment, color, and styling
- [ ] Assistant/AI message: markdown rendered correctly
- [ ] Code blocks: syntax highlighting applied, language label visible
- [ ] Multi-language content: correct font-family applied
- [ ] Tool call: name, status, expand/collapse detail
- [ ] Long content: text wraps, does not overflow container

### Navigation / Sidebar
- [ ] Item list: all items render with title
- [ ] Long titles: truncated with ellipsis
- [ ] Active item: highlighted with distinct style
- [ ] Context menu: appears on hover/click, contains expected actions

### Search / Filter Dialog
- [ ] Opens with correct title
- [ ] Input auto-focused on open
- [ ] Real-time filtering as user types
- [ ] Empty state when no results match
- [ ] Close via button and Escape key

### Forms / Settings
- [ ] All inputs have associated labels
- [ ] Select/dropdown options render correctly
- [ ] Save button disabled when no changes
- [ ] Validation errors displayed inline
- [ ] Close/cancel reverts unsaved changes

### Error States
- [ ] Network error: toast or banner shown, not blank page
- [ ] Invalid route: handled gracefully, not white screen
- [ ] Missing data: empty state with helpful message

---

## Integration / E2E Tests (Playwright)

### Authentication
- [ ] Unauthenticated visit to protected route → redirect to login
- [ ] Valid credentials → successful login → redirect to main page
- [ ] Invalid credentials → error shown, stays on login page
- [ ] Sign out → clears session → redirect to login

### Core User Flows
- [ ] Create new item → item appears in list
- [ ] Send message → message appears → response streams back
- [ ] Multi-turn conversation: 3+ messages all visible
- [ ] Long message (3000+ chars, mixed scripts) → no crash, content visible
- [ ] Rename item: UI reflects new name
- [ ] Delete item: item removed from list, redirected if viewing deleted item
- [ ] Search: opens, filters results, closes cleanly
- [ ] Toggle UI panels: collapse and expand correctly

### State Synchronization
- [ ] Rename → list and detail view both updated
- [ ] Delete active item → redirect to list page
- [ ] New item → appears at top of list
- [ ] Switch between items → correct content loads for each

### Console Cleanliness
- [ ] No `pageerror` events across all operations
- [ ] No unexpected `console.error` calls (500 responses, failed fetches)

---

## API Contract Tests

### List Endpoint
- [ ] `GET /api/items` → 200, returns array
- [ ] Each item has required fields (id, title, updatedAt)
- [ ] Pagination parameters work (limit, offset)

### Detail Endpoint
- [ ] `GET /api/items/:id` → 200, returns full object
- [ ] `GET /api/items/:nonexistent` → 404 with error body

### Create Endpoint
- [ ] `POST /api/items` with valid body → 201, returns created item
- [ ] `POST /api/items` with missing required fields → 400

### Update Endpoint
- [ ] `PUT /api/items/:id` → 200, returns updated item
- [ ] `PUT /api/items/:id` with empty required field → 400

### Delete Endpoint
- [ ] `DELETE /api/items/:id` → 200 or 204
- [ ] `DELETE /api/items/:nonexistent` → 404

### Streaming Endpoint (if SSE)
- [ ] `POST /api/chat` → 200, SSE stream with `text` and `end` events
- [ ] Partial response renders incrementally
