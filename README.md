# DD Agent Skills

A collection of portable, agent-agnostic skills for AI coding assistants. All skills use the `dd-` prefix convention.

Each skill is a self-contained Markdown file with patterns, checklists, and executable code templates. Designed to work with **Claude Code**, **Codex**, **Cursor**, **Hermes**, and **GitHub Copilot** — no agent-specific tool calls.

## Available Skills

### `dd-webapp-full-test`

Comprehensive web application testing across 6 dimensions:

| # | Dimension | What it tests |
|---|-----------|---------------|
| 1 | **Functional** | Unit tests, component tests, E2E flows, API contract validation |
| 2 | **Visual** | Screenshot regression, dark mode, responsive breakpoints (24 scenarios) |
| 3 | **Accessibility** | axe-core scans, keyboard navigation, focus management, ARIA labels |
| 4 | **Security** | XSS payload injection (50+ vectors), input validation, sensitive data leaks |
| 5 | **Compatibility** | Multi-browser, offline/slow network, multi-language rendering |
| 6 | **Performance** | Core Web Vitals, bundle analysis, API latency, CLS, Long Tasks, cache |

**Stack**: Playwright + Vitest + React Testing Library + axe-core. Framework-agnostic — adapts to Next.js, Vite, CRA, or any web app with a dev server.

**Files**: [`dd-webapp-full-test/SKILL.md`](dd-webapp-full-test/SKILL.md) + 4 reference checklists.

---

## Naming Convention

All skills use the `dd-` prefix:

```
dd-<skill-name>/
├── SKILL.md
└── references/
```

## How Skills Work

Each skill is a standalone `.md` file that coding agents read as instructions. When a user asks for a task that matches the skill's domain, the agent loads the skill and follows its patterns.

**Structure of a skill:**

```
dd-skill-name/
├── SKILL.md              # Main instructions: patterns, code templates, pitfalls
└── references/           # Detailed checklists, payload lists, metric definitions
    ├── checklist.md
    └── payloads.md
```

**What makes a good skill:**

- **Portable**: No tool calls specific to any one agent. Pure code patterns + checklists.
- **Actionable**: Copy-paste code templates, not abstract advice.
- **Complete**: Covers the happy path AND edge cases, pitfalls, and cleanup.
- **Self-contained**: All context needed is in the skill file (or its references).

## Usage

### With Claude Code

```bash
# Per-project
cp -r dd-webapp-full-test ~/my-project/.claude/skills/

# Or reference from CLAUDE.md:
# "For comprehensive testing, load .claude/skills/dd-webapp-full-test/SKILL.md"
```

### With Hermes

```bash
# Per-user
cp -r dd-webapp-full-test ~/.hermes/skills/

# Auto-triggered when user mentions "full test", "visual regression", etc.
```

### With Any Agent

Since skills use standard code patterns (Playwright, Vitest), any agent can execute them directly. Just tell the agent:

> "Test this app comprehensively using the patterns in `dd-webapp-full-test/SKILL.md`"

## Contributing

Skills follow a `dd-SKILL.md` + `references/` structure:

```
dd-your-skill/
├── SKILL.md              # Required: main skill file with patterns and instructions
└── references/           # Optional: detailed lists, tables, payload collections
    ├── checklist.md
    └── data.json
```

Guidelines:
- Prefix with `dd-`
- Pure English (code examples may contain non-English content for testing purposes)
- No agent-specific tool calls (`browser_snapshot`, `skill_view`, etc.)
- Code templates should be copy-paste ready
- Include a "Pitfalls" section with common mistakes
- Test your skill against a deliberately buggy app to verify it catches issues

## License

MIT
