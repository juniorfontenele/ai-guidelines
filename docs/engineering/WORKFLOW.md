# Development Workflow

**Purpose**: Define the development workflow from starting work to opening pull requests.

---

## Development Environment

### Starting the Dev Server

```bash
composer dev
```

This starts **all services concurrently**: Laravel server, queue worker, Pail (log tailing), and Vite (frontend HMR).

Access at: `http://localhost:8000`

For SSR mode: `composer dev:ssr`

If frontend changes are not reflected in the UI, run `npm run build` or restart `npm run dev`.

### First-Time Setup

```bash
composer setup
```

This runs: `composer install` → copy `.env` → `key:generate` → `migrate` → `npm install` → `npm run build`.

### Demo Data (optional)

If the project has demo seeders for development data:

```bash
php artisan db:seed --class='Database\Seeders\Demo\DemoSeeder'
```

Create demo seeders in `database/seeders/Demo/` for development testing data. Document credentials and test scenarios inline or in a project-specific `docs/DEMO_DATA.md`.

---

## Pre-Commit Checklist

Before **any** commit:

```bash
# PHP quality (MANDATORY)
composer lint

# Frontend quality
npm run lint
npm run types
```

If tests exist for the changed area:

```bash
composer test
```

No commits are allowed without passing `composer lint`.

---

## Git Workflow

### Branch Strategy

- Always create a new branch — never commit directly to `master`
- Branch from `master` unless working on an existing feature branch

### Branch Naming

```
<type>/<short-description>

Types:
- feat/       → New feature
- fix/        → Bug fix
- refactor/   → Code refactoring (no behavior change)
- chore/      → Tooling, dependencies, config
- docs/       → Documentation only
- test/       → Test additions or fixes
```

Examples:

```bash
git checkout -b feat/user-notifications
git checkout -b fix/login-redirect
git checkout -b refactor/payment-service
```

---

## Commit Guidelines

### Semantic Commits

```
<type>(<scope>): <short description>

[optional body explaining what and why]
```

Types: `feat`, `fix`, `refactor`, `chore`, `docs`, `test`, `style`, `perf`

Examples:

```
feat(auth): add two-factor authentication setup page

Implemented the 2FA configuration page using Fortify's TOTP support
with QR code display and recovery code management.
```

```
fix(notifications): prevent duplicate email on password reset
```

### Commit Rules

- **Atomic**: one logical change per commit
- **Complete**: the commit doesn't break the application
- **Descriptive**: clear what was changed and why
- **By activity, not by file**: `feat(auth): add login flow` not `update LoginController.php`

---

## Pull Request Workflow

### Before Opening a PR

**Ask the user first:**

> "Deseja que eu abra um Pull Request?"

Only open PRs when confirmed.

### PR Checklist

Before requesting review:

1. `composer lint` passes
2. `composer test` passes
3. `npm run lint` passes
4. `npm run types` passes
5. No `dd()`, `dump()`, `console.log()`, or debug code
6. No unused imports or TODOs without tickets
7. Documentation updated if needed

### PR Format

**Title**: `<type>: <short description>` (under 70 characters)

**Body**:

```markdown
## Summary

- What was done and why (2-3 bullet points)

## Test Plan

- [ ] How to verify the changes work

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

---

## AI-Assisted Development Workflow

### Development Pipeline

The project supports a structured AI-assisted development flow:

0. **`/brainstorming`** — Structure ideas, explore options, refine specs
1. **`/generate-prd`** — Define product requirements in `docs/PRD.md`
2. **`/generate-architecture`** — Create system architecture in `docs/architecture/`
3. **`/generate-ui-design`** — Define UI/UX design specifications in `docs/design/`
4. **`/generate-task-breakdown`** — Break requirements into tasks in `docs/tasks/`
5. **`/task-planner`** — Plan and optionally route to implementation
6. **`/implement-task`** — Implement individual tasks with quality gates

**Alternative**: **`/task-planner`** can plan + delegate to `implement-task` for features, tasks, or refactors from natural language descriptions.

### Available Skills

| Skill                       | Purpose                                        |
| --------------------------- | ---------------------------------------------- |
| `brainstorming`             | Ideation, spec refinement, layout/UI planning  |
| `task-planner`              | Plan + route features, tasks, or refactors     |
| `frontend-development`      | React + Inertia + Tailwind + Radix + Wayfinder |
| `generate-test`             | PestPHP test generation                        |
| `developing-with-fortify`   | Auth reference (login, 2FA, password reset)    |
| `security-analyst`          | OWASP Top 10 security review                   |
| `browser-qa-tester`         | Autonomous UX/UI QA via browser subagent       |
| `project-qa-auditor`        | QA audit before PR/deploy                      |
| `bug-fixer`                 | Fix bugs from GitHub Issues or user reports    |
| `i18n-manager`              | i18n audit, fix, and translation sync          |
| `generate-persona`          | Generate structured persona profiles           |
| `generate-persona-feedback` | Simulate persona behavior, generate feedback   |
| `skill-creator`             | Creating new skills                            |

### Using Laravel Boost (MCP)

Laravel Boost provides tools for AI-assisted development:

- `search-docs` — Search version-specific documentation (always use before coding)
- `list-artisan-commands` — Check available artisan commands and parameters before running them
- `tinker` — Execute PHP in application context (prefer tests over tinker for verification)
- `database-schema` — Inspect table structure before writing migrations or models
- `database-query` — Run read-only SQL queries
- `last-error` — Get last backend error/exception
- `browser-logs` — Read recent frontend console logs (old logs are stale)
- `list-routes` — List application routes
- `get-absolute-url` — Get correct URLs when sharing with user

#### search-docs Query Syntax

Use multiple broad queries: `['rate limiting', 'routing rate limiting']`. Do not add package names to queries. Pass a `packages` array to filter results when targeting specific packages.

- Simple words with auto-stemming: `authentication` finds `authenticate` and `auth`
- Multiple words (AND): `rate limit` finds entries with both terms
- Quoted phrases: `"infinite scroll"` matches exact adjacent words
- Mixed: `middleware "rate limit"` combines AND + exact phrase
- Multiple queries: `["authentication", "middleware"]` matches ANY term

---

## Available Scripts

> For the complete list of PHP and JavaScript scripts, see [STACK.md](STACK.md#available-scripts).

---

## Workflow Summary

```bash
# 1. Create feature branch
git checkout -b feat/my-feature

# 2. Start development server
composer dev

# 3. Make changes (backend + frontend)

# 4. Run quality checks
composer lint && npm run lint && npm run types

# 5. Run tests
composer test

# 6. Commit changes
git add <files>
git commit -m "feat(scope): description"

# 7. Push and ask about PR
git push origin feat/my-feature
# "Deseja que eu abra um Pull Request?"
```

---

## Related Documentation

- **[STACK.md](STACK.md)** — Tech stack and dependencies
- **[CODE_STANDARDS.md](CODE_STANDARDS.md)** — Code quality and conventions
- **[TESTING.md](TESTING.md)** — Testing guidelines
