# DD Agent Skills

Portable, agent-agnostic skills for AI coding assistants. All skills use the `dd-` prefix convention.

**Works with**: Claude Code, Codex, Cursor, Hermes, GitHub Copilot — zero agent-specific tool calls.

## Available Skills

### `dd-webapp-full-test`

Comprehensive web application testing across 6 dimensions. Tell your agent *"test my app thoroughly"* and get a complete audit.

| Step | Output |
|------|--------|
| 1. Pre-flight | Detects framework, build tool, installed tools, missing deps |
| 2. Lock dimensions | User confirms which 6 dimensions run, which skip |
| 3. Execution plan | Detailed per-dimension plan — exactly what gets tested, user approves |
| 4. Execute | All dimensions run in order: functional → visual → a11y → security → compatibility → performance |
| 5. Report | `TEST-REPORT.md` at project root with pass/fail, issues, recommendations |
| 6. Cleanup | Temporary artifacts removed; scripts + report kept |

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

**Files**: [`dd-webapp-full-test/SKILL.md`](dd-webapp-full-test/SKILL.md) + 3 pre-flight scripts + 4 reference checklists.

### Critical Rules (agent-enforced)

The skill instructs agents to follow three hard rules:

1. **Never modify business code** — write tests to `e2e/`, write results to `TEST-REPORT.md`. Never touch application logic, components, styles, or config. All issues go into the report; the user decides what to fix.
2. **Test results are facts** — `PASS`, `FAIL`, or `SKIP` only. No "this is fine" judgments.
3. **Ask before installing** — never `npm install` without explicit user confirmation.

### Pre-flight Scripts

Three fallback scripts auto-detect your stack. Agent tries each in order:

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

After installing, the agent will ask whether to add a reference to `CLAUDE.md` or `AGENTS.md`. If accepted, it appends:

```markdown
## Testing

Run comprehensive tests with the dd-webapp-full-test skill:

- "test my app thoroughly" — runs 6-dimension audit (functional, visual, a11y, security, compatibility, performance)
- "run all 6 test dimensions" — same
- "comprehensive test" — same
- "security scan" — dimension 4 only

Skill location: `.claude/skills/dd-webapp-full-test/SKILL.md` (or your agent's skill directory).
Tests are written to `e2e/`. Results in `TEST-REPORT.md`.
```

## Naming Convention

All skills use the `dd-` prefix:

```
dd-<skill-name>/
├── SKILL.md              # Main instructions: patterns, code templates, pitfalls
├── scripts/              # Pre-flight checks, helpers
└── references/           # Detailed checklists, payload lists, metric definitions
```

## Contributing

Guidelines:
- Prefix with `dd-`
- Pure English (code examples may contain non-English content for testing)
- No agent-specific tool calls
- Include a "Pitfalls" section with common mistakes
- Include a "CRITICAL RULES" section that forbids agents from modifying business code
- Test your skill against a deliberately buggy app to verify it catches issues
- Be mindful of LLM content filters — avoid putting raw security payloads in the main SKILL.md; use separate data/ files instead (not auto-loaded by agents)

## License

MIT
