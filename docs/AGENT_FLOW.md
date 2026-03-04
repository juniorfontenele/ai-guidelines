# Agent Flow — Development Lifecycle Orchestration

Map of the complete AI-assisted development pipeline, skill routing, and quality checkpoints.

---

## 1. Lifecycle Overview

```text
  ┌──────────────┐     ┌─────────────┐     ┌────────────────────┐     ┌─────────────────┐
  │ Brainstorming │────▶│ Generate PRD│────▶│ Generate           │────▶│ Generate UI     │
  │              │     │             │     │ Architecture       │     │ Design          │
  └──────────────┘     └─────────────┘     └────────────────────┘     └─────────────────┘
         │                                                                    │
         │  (clarity sufficient)                                              │
         ▼                                                                    ▼
  ┌──────────────┐                                                   ┌─────────────────┐
  │ Task Planner │◀──────────────────────────────────────────────────│ Generate Task   │
  │ (plan only)  │                                                   │ Breakdown       │
  └──────┬───────┘                                                   └─────────────────┘
         │                                                                    │
         ▼                                                                    ▼
  ┌──────────────┐     ┌─────────────┐     ┌────────────────────┐     ┌─────────────────┐
  │ Implement    │────▶│ Quality     │────▶│ Code Review        │────▶│ Deploy          │
  │ Task         │     │ Gates       │     │ (/code-review)     │     │ (/deploy)       │
  └──────────────┘     └─────────────┘     └────────────────────┘     └─────────────────┘
```

### Entry Points

| Starting Point          | Entry Skill/Workflow             | When                         |
| ----------------------- | -------------------------------- | ---------------------------- |
| Don't know what to do   | `/helpme` workflow               | Universal orchestrator       |
| From zero, vague idea   | `brainstorming`                  | Ideation, exploration        |
| Clear feature in mind   | `generate-prd` or `task-planner` | Requirements are known       |
| PRD already exists      | `generate-architecture`          | Architecture needed          |
| Tasks already exist     | `implement-task`                 | Ready to code                |
| Bug report              | `bug-fixer` or `/debug`          | Issue needs investigation    |
| Quick fix (known cause) | `implement-task`                 | Simple, direct fix           |
| UI looks bad            | `/improve-ui` workflow           | Visual/UX improvement needed |
| Code needs cleanup      | `/refactor` workflow             | Restructuring, tech debt     |

---

## 2. Skill Routing Table

### By User Intent

| User Intent                          | Primary Skill                                    | Supporting Skills                             |
| ------------------------------------ | ------------------------------------------------ | --------------------------------------------- |
| "Quero criar algo novo"              | `brainstorming` → `generate-prd`                 | `generate-architecture`, `generate-ui-design` |
| "Implementar feature X"              | `task-planner`                                   | `frontend-development`, `generate-test`       |
| "Corrigir bug #N"                    | `bug-fixer`                                      | `generate-test`                               |
| "Refatorar módulo X"                 | `task-planner` (refactor)                        | `code-reviewer`, `generate-test`              |
| "Redesenhar tela Y"                  | `brainstorming` (layout)                         | `generate-ui-design`, `frontend-development`  |
| "Review de segurança"                | `security-analyst`                               | `project-qa-auditor`                          |
| "Auditar antes do PR"                | `/code-review` workflow                          | `security-analyst`, `code-reviewer`           |
| "Qual é o status?"                   | `/status` workflow                               | —                                             |
| "Preciso de testes"                  | `generate-test`                                  | —                                             |
| "Autenticação"                       | `developing-with-fortify`                        | `frontend-development`                        |
| "Traduzir / i18n"                    | `i18n-manager`                                   | —                                             |
| "Criar nova skill"                   | `skill-creator`                                  | `brainstorming` (skill)                       |
| "Não sei por onde começar"           | `/helpme` workflow or `brainstorming` (guidance) | —                                             |
| "Adicionar suporte a Node/Python/Go" | `/add-stack` workflow                            | `init-project`                                |
| "Debug / investigar bug"             | `/debug` workflow                                | `bug-fixer`                                   |
| "Refatorar módulo X"                 | `/refactor` workflow                             | `code-reviewer`, `generate-test`              |
| "Rodar testes"                       | `/test` workflow                                 | `generate-test`                               |
| "Atualizar documentação"             | `/docs` workflow                                 | `generate-architecture`, `generate-prd`       |
| "Melhorar visual / UI feia"          | `/improve-ui` workflow                           | `frontend-development`, `browser-qa-tester`   |

### Chaining Rules

- **Never run `implement-task` on complex tasks without planning first** — route through `task-planner`
- **Always run quality gates after `implement-task`** — lint, test, security
- **Always route auth features through `developing-with-fortify`** — even if user asks `implement-task`
- **Frontend changes should reference `frontend-development`** — patterns compound

---

## 3. Quality Checkpoints

### During Implementation (every task)

```text
Code Change ──▶ Lint ──▶ Test (3 pillars) ──▶ Security ──▶ Commit
```

- **Lint**: `composer lint` / stack equivalent (MANDATORY)
- **Test**: Happy path + Unhappy path + Security path (MANDATORY)
- **Security**: `security-analyst` on changed files (CRITICAL/HIGH block)

### Pre-PR

```text
All Commits ──▶ /code-review ──▶ PR
```

- Full lint + test suite
- Code quality review
- Security review on changed files

### Pre-Deploy

```text
PR Merged ──▶ /deploy ──▶ Production
```

- Quality gates pass
- Translations sync
- Build success
- Migrations reviewed

---

## 4. Cross-Cutting Concerns

### When to Run Each

| Concern      | When                                          | Skill/Tool                   |
| ------------ | --------------------------------------------- | ---------------------------- |
| **i18n**     | After adding user-facing strings              | `i18n-manager`               |
| **Security** | After changing auth, permissions, data access | `security-analyst`           |
| **Tests**    | After any code change                         | `generate-test`              |
| **Docs**     | After architecture/API changes                | Manual (see `CLAUDE.md` §10) |
| **Progress** | Before/after each task in a batch             | `implement-task` (built-in)  |

### Gap Detection

When any skill detects that a required stack pack is missing:

1. Check `.agents/skills/stack-*` for the relevant pack
2. If missing, suggest: `> ⚠️ Stack pack not found. Run /add-stack to activate.`
3. Do NOT block — continue with best-effort using core skills
