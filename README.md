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

## Installation

Each skill follows the same install pattern. An AI agent given this repo URL + a skill name should:

1. Clone or download the repo
2. Copy the skill directory to the agent-specific location
3. Verify the `SKILL.md` + `references/` are in place

### Agent-Specific Install Paths

| Agent | Skills Directory | Discovery |
|-------|-----------------|-----------|
| **Claude Code** | `<project>/.claude/skills/` | Referenced from `CLAUDE.md` or loaded automatically |
| **Hermes** | `~/.hermes/skills/` | Auto-discovered by frontmatter `triggers` |
| **Codex / Cursor** | `<project>/.codex/skills/` | Referenced from `AGENTS.md` |
| **GitHub Copilot** | `<project>/.github/copilot/` | Referenced from `.github/copilot-instructions.md` |

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

### Install a Single Skill Manually

```bash
# From the repo root
AGENT_SKILLS_DIR=".claude/skills"  # change to your agent's path
SKILL="dd-webapp-full-test"

mkdir -p "$AGENT_SKILLS_DIR"
cp -r "$SKILL" "$AGENT_SKILLS_DIR/"
echo "Installed $SKILL → $AGENT_SKILLS_DIR/$SKILL/"
```

### Verify Installation

```bash
# Check the skill file exists
cat .claude/skills/dd-webapp-full-test/SKILL.md | head -5

# Should show:
# ---
# name: dd-webapp-full-test
# description: |
#   Comprehensive web app testing covering 6 dimensions...
```

### After Install — Reference in Project Config

Add to `CLAUDE.md` (Claude Code) or `AGENTS.md` (Codex):

```markdown
## Testing

For comprehensive testing, load `.claude/skills/dd-webapp-full-test/SKILL.md`.
Covers: functional, visual regression, accessibility, security, compatibility, performance.
```

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
