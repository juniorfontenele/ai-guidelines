# Contributing to AI Development Guidelines

Thank you for your interest in contributing! This document explains how the project is structured and how to contribute effectively.

---

## Project Structure

```text
.agents/
├── skills/          # Specialized AI skill executors
│   └── <skill>/
│       ├── SKILL.md         # Main instructions (frontmatter + markdown)
│       └── references/      # Optional supplementary docs
├── workflows/       # Orchestrator slash commands (.md files)
├── rules/           # Always-on enforcement rules
└── scripts/         # Helper shell scripts

.claude/
└── skills/          # Mirror of .agents/skills/ for Claude Code

docs/
├── engineering/     # Code standards, testing, workflow, quality gates
├── architecture/    # System architecture (template)
├── design/          # UI/UX specs (template)
└── AGENT_FLOW.md    # Canonical lifecycle doc
```

> **Important**: `.agents/skills/` and `.claude/skills/` must always stay in sync.

---

## Creating a New Skill

Use the `skill-creator` skill for guided creation, or follow these steps:

### 1. Create the skill directory

```bash
mkdir -p .agents/skills/<skill-name>/
mkdir -p .claude/skills/<skill-name>/
```

### 2. Create `SKILL.md` with frontmatter

```yaml
---
name: <skill-name>
description: "One-line description for intent matching. Include trigger phrases."
dependencies:
  skills: []   # Other skills this skill may invoke
  docs: []     # Docs this skill references
---

# Skill Name

## Completion Criteria
- [ ] What must be true when this skill completes

## Workflow

### 1. Step Name
Instructions...

### 2. Step Name
Instructions...
```

### 3. Optionally add references

Place supplementary docs in `references/`:

```text
<skill-name>/
├── SKILL.md
└── references/
    ├── patterns.md
    └── checklist.md
```

### 4. Mirror to `.claude/skills/`

```bash
cp -r .agents/skills/<skill-name> .claude/skills/
```

### 5. Update routing (if applicable)

If the skill handles common user intents, add it to the routing table in `docs/AGENT_FLOW.md` §2.

---

## Creating a New Workflow

### 1. Create the workflow file

```bash
touch .agents/workflows/<workflow-name>.md
```

### 2. Add YAML frontmatter + steps

````yaml
---
description: "One-line description. Include trigger examples (e.g., 'use when...')."
---

# Workflow Name

## Steps

1. **Step name**:
   Instructions...

2. **Step name**:
   // turbo
   ```bash
   # Commands with // turbo can be auto-run
   echo "hello"
   ```
````

### Annotations

- `// turbo` before a step → agent can auto-run that specific step
- `// turbo-all` anywhere → agent can auto-run ALL steps in the workflow

---

## Creating a Stack Pack

Stack packs are additive configuration skills for specific technologies.

### 1. Create the skill

Follow the same structure as a regular skill at `.agents/skills/stack-<name>/SKILL.md`.

### 2. Required sections

| Section       | What to include                              |
| ------------- | -------------------------------------------- |
| Standards     | Language/framework-specific coding standards |
| Linting       | Tool configuration and commands              |
| Testing       | Framework, patterns, commands                |
| Quality Gates | Stack-specific gate commands                 |
| Patterns      | Idiomatic patterns and anti-patterns         |

### 3. Update detection

Add detection rules to `.agents/skills/init-project/SKILL.md` detection rules section.

### 4. Update quality gate script

Add new gate commands to `.agents/scripts/verify-quality-gates.sh`.

---

## Testing Your Changes

### CLI tests

```bash
npm test
```

This runs the CLI tests and guidelines validation suite.

### Guidelines validation

```bash
bash tests/validate-guidelines.sh
```

This validates: frontmatter, relative paths, skill sync, workflow references, and stub detection.

---

## Submitting PRs

### Branch naming

```text
feat/<description>     # New skills, workflows, features
fix/<description>      # Bug fixes
docs/<description>     # Documentation updates
refactor/<description> # Restructuring
```

### Commit format

```text
<type>(<scope>): <description>

Types: feat, fix, docs, refactor, style, test, chore
Scope: skill name, workflow name, or component
```

### PR checklist

- [ ] `npm test` passes
- [ ] `bash tests/validate-guidelines.sh` passes
- [ ] `.agents/skills/` and `.claude/skills/` are in sync
- [ ] No absolute file paths in `.md` files
- [ ] New skills have `dependencies` frontmatter
- [ ] CHANGELOG.md updated
- [ ] README.md updated if adding new skills/workflows
