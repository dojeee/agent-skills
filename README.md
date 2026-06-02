# DD Agent Skills

Portable, agent-agnostic skills for AI coding assistants. All skills use the `dd-` prefix convention.

**Works with**: Claude Code, Codex, Cursor, Hermes, GitHub Copilot — zero agent-specific tool calls.

## Available Skills

### `dd-webapp-full-test`

Comprehensive web application testing across 6 dimensions. Tell your agent *"test my app thoroughly"* and get a complete audit.

| Step | Output |
|------|--------|
| 1. Discovery | Agent explores your app, identifies routes, components, selectors |
| 2. Test Generation | 6 test spec files written to `e2e/` |
| 3. Execution | All 6 dimensions run in order |
| 4. Report | `TEST-REPORT.md` at project root with pass/fail, issues, recommendations |
| 5. Cleanup | Temporary artifacts removed; scripts + report kept |

| # | Dimension | What it tests |
|---|-----------|---------------|
| 1 | **Functional** | Unit tests, component tests, E2E flows, API contract validation |
| 2 | **Visual** | Screenshot regression, dark mode, responsive breakpoints (24 scenarios) |
| 3 | **Accessibility** | axe-core scans, keyboard navigation, focus management, ARIA labels |
| 4 | **Security** | HTML output safety, input validation, header checks, sensitive data leaks |
| 5 | **Compatibility** | Multi-browser, offline/slow network, multi-language rendering |
| 6 | **Performance** | Core Web Vitals, bundle analysis, API latency, CLS, Long Tasks, cache |

> ⚠️ **Provider note**: Some LLM providers (Kimi, Moonshot, enterprise gateways) may flag security test content. The skill handles this gracefully — skips affected tests, notes it in the report, and continues normally.

**Stack**: Playwright + Vitest + React Testing Library + axe-core.

**Files**: [`dd-webapp-full-test/SKILL.md`](dd-webapp-full-test/SKILL.md) + 4 reference checklists.

---

## Installation

### Install via Agent

Tell your agent:

> "Install `dd-webapp-full-test` from https://github.com/dojeee/agent-skills"

The agent should execute:

```bash
# Clone the repo
git clone https://github.com/dojeee/agent-skills /tmp/agent-skills

# Copy to the correct location for YOUR agent:
# Claude Code (per-project):
mkdir -p .claude/skills
cp -r /tmp/agent-skills/dd-webapp-full-test .claude/skills/

# Hermes (per-user):
mkdir -p ~/.hermes/skills
cp -r /tmp/agent-skills/dd-webapp-full-test ~/.hermes/skills/

# Codex / Cursor (per-project):
mkdir -p .codex/skills
cp -r /tmp/agent-skills/dd-webapp-full-test .codex/skills/

# Verify
ls .claude/skills/dd-webapp-full-test/SKILL.md  # or your agent's path
ls .claude/skills/dd-webapp-full-test/references/

# Cleanup
rm -rf /tmp/agent-skills
```

### Agent-Specific Paths

| Agent | Skills Directory | Discovery |
|-------|-----------------|-----------|
| **Claude Code** | `<project>/.claude/skills/` | Referenced from `CLAUDE.md` |
| **Hermes** | `~/.hermes/skills/` | Auto-discovered by triggers |
| **Codex / Cursor** | `<project>/.codex/skills/` | Referenced from `AGENTS.md` |
| **GitHub Copilot** | `<project>/.github/copilot/` | `.github/copilot-instructions.md` |

### Verify Installation

```bash
cat .claude/skills/dd-webapp-full-test/SKILL.md | head -6
# Should show:
# ---
# name: dd-webapp-full-test
# description: |
#   Comprehensive web app testing across 6 dimensions...
```

### Post-Install — Reference in Project Config

```markdown
# CLAUDE.md or AGENTS.md

## Testing
For comprehensive testing (6 dimensions: functional, visual, a11y, security,
compatibility, performance), load `.claude/skills/dd-webapp-full-test/SKILL.md`.
```

## Naming Convention

All skills use the `dd-` prefix:

```
dd-<skill-name>/
├── SKILL.md              # Main instructions: patterns, code templates, pitfalls
└── references/           # Detailed checklists, payload lists, metric definitions
```

## Contributing

Guidelines:
- Prefix with `dd-`
- Pure English (code examples may contain non-English content for testing)
- No agent-specific tool calls
- Include a "Pitfalls" section with common mistakes
- Test your skill against a deliberately buggy app to verify it catches issues
- Be mindful of LLM content filters — avoid putting raw security payloads in the main SKILL.md; use references/ files instead

## License

MIT
