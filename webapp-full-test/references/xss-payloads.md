# XSS & Security Testing Payloads

## HTML Injection

```
<script>alert("xss")</script>
<SCRIPT>alert("xss")</SCRIPT>
<ScRiPt>alert("xss")</ScRiPt>
<script>alert(document.cookie)</script>
```

## Image / Event Handlers

```
<img src=x onerror=alert(1)>
<img src=x onerror="alert('xss')">
<img src=1 onmouseover=alert(1)>
<img src=1 onload=alert(1)>
<IMG SRC="javascript:alert(1)">
```

## SVG

```
<svg onload=alert(1)>
<svg><script>alert(1)</script></svg>
<svg/onload=alert(1)>
```

## URL / Link

```
javascript:alert(1)
[click](javascript:alert(1))
<a href="javascript:alert(1)">click</a>
```

## Event Handler Attributes

```
" onclick="alert(1)"
' onclick='alert(1)'
" onfocus="alert(1)" autofocus="true"
" onmouseover="alert(1)"
" onload="alert(1)"
```

## Body / Iframe

```
<body onload=alert(1)>
<iframe src="javascript:alert(1)">
<iframe srcdoc="<script>alert(1)</script>">
```

## CSS Injection

```
<style>body{display:none}</style>
<div style="background:url(javascript:alert(1))">
```

## Encoding Variants

```
&#60;script&#62;alert(1)&#60;/script&#62;
%3Cscript%3Ealert(1)%3C/script%3E
\x3Cscript\x3Ealert(1)\x3C/script\x3E
\u003Cscript\u003Ealert(1)\u003C/script\u003E
```

## Markdown Injection

```
[text](javascript:alert(1))
![img](x onerror=alert(1))
<script>alert(1)</script>
```

## Polyglot (multi-context payload)

```
jaVasCript:/*-/*`/*\`/*'/*"/**/(/* */oNcliCk=alert(1) )//%0D%0A%0d%0a//</stYle/</titLe/</teXtarEa/</scRipt/--!>\x3csVg/<sVg/oNloAd=alert(1)//>\x3e
```

## Expected Behavior

For a secure chat app, ALL of these should be **rendered as plain text** — the user sees the literal string, no script executes, no dialog appears.

## Test Method (Playwright)

```ts
test("XSS payloads are escaped", async ({ page }) => {
  // Inject each payload into chat content and verify:
  // 1. The payload text is visible on the page (rendered as text)
  // 2. No alert/confirm dialog appeared
  // 3. No unexpected navigation

  for (const payload of XSS_PAYLOADS) {
    const dialogPromise = new Promise((_, reject) => {
      page.once("dialog", () => reject(new Error(`XSS: ${payload}`)));
      setTimeout(() => {}, 2000);
    });

    // Display payload in chat (inject via content or send as message)
    await expect(page.getByText(payload, { exact: false })).toBeVisible();
  }
});
```

## Input Validation Payloads

```
(empty string)
"   " (whitespace only)
"a".repeat(100000) (very long)
"\u200B" (zero-width space)
"\u0000" (null byte)
"'; DROP TABLE chats;--" (SQL injection)
"${7*7}" (template injection)
"{{7*7}}" (template injection)
"<!--" (HTML comment)
"-->" (close comment)
```

## Error Message Leak Check

Check that error responses don't contain:
- Stack traces: `Error: `, `at `, `.ts:`, `.js:`
- Internal paths: `/Users/`, `/home/`, `/app/`
- Database details: `PostgreSQL`, `table`, `column`
- Server software: `Express`, `Next.js`, version numbers
