# Quality Gates

**Purpose**: Define the mandatory quality gates that must pass before completing any development task, feature, or bug fix.

---

## Gate 1: Code Quality (Lint)

Run all static analysis and formatting checks:

```bash
# PHP: format + rector + analyze (MANDATORY)
composer lint

# Frontend: ESLint + TypeScript (MANDATORY if frontend files were modified)
npm run lint && npm run types
```

**If lint fails:**

1. Fix reported issues
2. Re-run the failing command
3. Commit fixes: `style: fix lint issues`

During AI development, use `vendor/bin/pint --dirty --format agent` for incremental PHP formatting.

---

## Gate 2: Tests

### When Tests Are Required by the Task

1. Invoke the **generate-test** skill to create appropriate tests
2. Tests MUST pass before proceeding
3. Commit: `test(scope): add tests for [feature]`

### When No New Tests Are Required

```bash
composer test
```

Existing tests must still pass — the change must not introduce regressions.

### When Tests Fail

1. Analyze failure — is the test wrong or the code wrong?
2. Fix appropriately
3. Re-run until passing

---

## Gate 3: Security Analysis

Invoke the **security-analyst** skill on files created or modified.

| Finding Severity     | Action                                     |
|----------------------|--------------------------------------------|
| 🔴 **CRITICAL**     | Must fix before completing                 |
| 🟠 **HIGH**         | Must fix before completing                 |
| 🟡 **MEDIUM**       | Inform user, proceed with their decision   |
| 🔵 **LOW**          | Inform user, proceed with their decision   |
| ⚪ **INFO**         | Optional improvement                       |

If CRITICAL or HIGH findings: commit fixes as `fix(security): [description]`.

---

## Gate Execution Order

Always execute gates in this order:

1. **Gate 1** (Lint) — fix formatting and static analysis first
2. **Gate 2** (Tests) — verify behavior is correct
3. **Gate 3** (Security) — validate no vulnerabilities introduced

---

## Gate Failure Handling

If any gate fails:

1. Report the failure clearly
2. Propose a fix
3. Ask the user how to proceed:
   - **Fix and retry** — attempt to fix the issue
   - **Skip with justification** — proceed despite failure (user must confirm)
   - **Abort** — stop the current task

---

## Related Documentation

- **[WORKFLOW.md](WORKFLOW.md)** — Pre-commit checklist and PR requirements
- **[TESTING.md](TESTING.md)** — Testing philosophy and practices
- **[CODE_STANDARDS.md](CODE_STANDARDS.md)** — Code quality conventions
