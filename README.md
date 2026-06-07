# DD Agent Skills

Portable skills for AI coding assistants. All skills use the `dd-` prefix convention.

**Works with**: Codex/OpenAI skills, Claude Code, Cursor, Hermes, and GitHub Copilot. Skill instructions avoid agent-specific tool calls unless an installing agent adds its own wrapper.

## Available Skills

### `dd-web-full-test`

Comprehensive web application testing across 6 dimensions. Tell your agent *"test my app thoroughly"* and get a complete audit.

| Phase | Output |
|-------|--------|
| 0. Scope | Target app, tested URL, credentials/data needs, report-only boundary |
| 1. Pre-flight | Framework, build tool, server status, installed tools, missing deps |
| 2. Dependency gate | Install request or skipped dimensions recorded |
| 3. Coverage plan | Dimension-by-dimension plan, test files, commands, artifacts |
| 4. Surface discovery | Routes, flows, selectors, APIs, visual states, breakpoints |
| 5. Test build | Focused test files under `e2e/`, `tests/`, or existing test paths |
| 6. Execute | Functional → visual → a11y → security → compatibility → performance |
| 7. Report | `TEST-REPORT.html` with evidence, failures, skips, recommendations |
| 8. Handoff | Chat summary with top findings and cleanup recommendation |

| # | Dimension | What it tests |
|---|-----------|---------------|
| 1 | **Functional** | Unit tests, component tests, E2E flows, API contract validation |
| 2 | **Visual** | Screenshot regression, dark mode, responsive breakpoints (24 scenarios) |
| 3 | **Accessibility** | axe-core scans, keyboard navigation, focus management, ARIA labels |
| 4 | **Security** | HTML output safety, input validation, header checks, sensitive data leaks |
| 5 | **Compatibility** | Multi-browser, offline/slow network, multi-language rendering |
| 6 | **Performance** | Core Web Vitals, bundle analysis, API latency, CLS, Long Tasks, cache |

> **Provider note**: Some LLM providers or enterprise gateways may flag security test content. The skill handles this gracefully — skips affected tests, notes it in the report, and continues normally.

**Stack**: Playwright + Vitest + React Testing Library + axe-core.

**Files**: [`dd-web-full-test/SKILL.md`](dd-web-full-test/SKILL.md), `agents/openai.yaml`, 3 pre-flight scripts, 3 checklist references, 1 report template, and optional security payload data.

### Critical Rules (agent-enforced)

The skill instructs agents to follow three hard rules:

1. **Never modify business code** — write tests to `e2e/`, write results to `TEST-REPORT.html`. Never touch application logic, components, styles, or config. All issues go into the report; the user decides what to fix.
2. **Test results are facts** — `PASS`, `FAIL`, or `SKIP` only. No "this is fine" judgments.
3. **Ask before installing** — never `npm install` without explicit user confirmation.

### Pre-flight Scripts

Three fallback scripts auto-detect your stack. The agent tries each in order:

| Script | Runtime | When |
|--------|---------|------|
| `scripts/preflight.mjs` | Node.js | Always works (Playwright needs Node) |
| `scripts/preflight.py` | Python 3 | Fallback |
| `scripts/preflight.sh` | Bash | Unix/macOS fallback (timeout-safe) |

Output: JSON with framework, build tool, installed tools, missing dependencies.

### Supported Frameworks

Auto-detected and pattern-adapted: React, Next.js, Vue 2/3, Angular, Svelte, SolidJS, Vanilla HTML/JS.

---

## Installation

### Install via Agent

Tell your agent:

> "Install `dd-web-full-test` from https://github.com/dojeee/agent-skills"

The agent should execute:

```bash
# Clone the repo
git clone https://github.com/dojeee/agent-skills /tmp/agent-skills

# Copy to the correct location for YOUR agent:
# Claude Code (per-project):
mkdir -p .claude/skills
cp -r /tmp/agent-skills/dd-web-full-test .claude/skills/

# Hermes (per-user):
mkdir -p ~/.hermes/skills
cp -r /tmp/agent-skills/dd-web-full-test ~/.hermes/skills/

# Codex / Cursor (per-project):
mkdir -p .codex/skills
cp -r /tmp/agent-skills/dd-web-full-test .codex/skills/

# Verify
ls .claude/skills/dd-web-full-test/SKILL.md  # or your agent's path
ls .claude/skills/dd-web-full-test/references/

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
cat .claude/skills/dd-web-full-test/SKILL.md | head -6
# Should show:
# ---
# name: dd-web-full-test
# description: Comprehensive report-only web application QA...
```

### Post-Install — Reference in Project Config

After installing, the agent will ask whether to add a reference to `CLAUDE.md` or `AGENTS.md`. If accepted, it appends:

```markdown
## Testing

Run comprehensive tests with the dd-web-full-test skill:

- "test my app thoroughly" — runs 6-dimension audit (functional, visual, a11y, security, compatibility, performance)
- "run all 6 test dimensions" — same
- "comprehensive test" — same
- "security scan" — dimension 4 only

Skill location: `.claude/skills/dd-web-full-test/SKILL.md` (or your agent's skill directory).
Tests are written to `e2e/`. Results in `TEST-REPORT.html`.
```

## Naming Convention

All skills use the `dd-` prefix:

```
dd-<skill-name>/
├── SKILL.md              # Main instructions and resource map
├── agents/openai.yaml    # OpenAI/Codex platform display metadata
├── scripts/              # Pre-flight checks, helpers
└── references/           # Detailed checklists, templates, metric definitions
```

## Contributing

Guidelines:
- Prefix with `dd-`
- Keep `SKILL.md` concise; move long templates and checklists into `references/`
- Put all trigger guidance in the frontmatter `description`
- Use only `name` and `description` in `SKILL.md` frontmatter for Codex/OpenAI compatibility
- Include `agents/openai.yaml` for platform display metadata
- Use pure English instructions; examples may contain non-English content for rendering tests
- Avoid agent-specific tool calls in the skill body
- Include a pitfalls section with common mistakes
- Include hard rules that forbid agents from modifying business code
- Test your skill against a deliberately buggy app to verify it catches issues
- Be mindful of LLM content filters; keep raw security payloads out of `SKILL.md` and load `data/` files only when needed

## License

MIT
