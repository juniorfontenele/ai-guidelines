---
trigger: always_on
---

# Quality Shield (ENFORCED)

Complementary rule to `00-bootstrap.md`. Enforces view impact analysis,
visual consistency, and documentation maintenance on every change.

---

## 1. Engineering Philosophy

> For full standards, see `CLAUDE.md` §4 and `docs/engineering/CODE_STANDARDS.md`.

---

## 2. View Impact Analysis

Before implementing any change, ALWAYS identify:

1. **Which views are affected**: client, pentester, admin, global-admin — or a combination?
2. **Is it single-view or cross-view?** Cross-view changes require consistency validation
3. **Role-based visibility**: consider what each role can see
   - Example: clients NEVER see pre-validation vulnerability statuses (`draft`, `awaiting_validation`, `validation_rejected`)
4. **Data consistency**: if the same data appears in multiple views, ensure consistent formatting and behavior

State the affected views explicitly in the response summary.

> Reference: `docs/architecture/DATA_FLOW.md` §8 (View Switching Flow), `docs/architecture/SECURITY.md` §2 (RBAC)

---

## 3. Testing Standards

> For full testing standards, see `docs/engineering/TESTING.md`.
> For security testing patterns, see `docs/architecture/SECURITY.md` §1.

---

## 4. Configuration Hierarchy

> For configuration resolution order and rules, see `docs/architecture/CONFIGURATION.md`.

---

## 5. i18n Enforcement

> For i18n rules, see `docs/engineering/CODE_STANDARDS.md` §i18n.

---

## 6. Visual Consistency & Theming

Every UI change MUST support both dark and light modes:

### Design System Compliance

- Use design tokens from `docs/design/DESIGN_SYSTEM.md` — NEVER ad-hoc colors or spacing
- Use existing components from `resources/js/components/` before creating new ones
- Use `class-variance-authority` for component variants
- Use `tailwind-merge` + `clsx` for conditional classes
- OKLCH color space for automatic dark mode derivation

### Tenant Customization

Some visual elements are **tenant-customizable** and must be respected:

- **Primary/secondary colors** — tenant branding via `tenant.settings`
- **Title** (`display_title`) — shown in headers, browser tab
- **Logo / Favicon** — tenant-uploaded assets
- Dark mode variants of tenant colors are auto-derived (OKLCH lightness adjustment)
- NEVER override tenant branding with hardcoded values

### Checklist (for every UI change)

- [ ] Works in light mode
- [ ] Works in dark mode
- [ ] Respects tenant branding colors (primary, secondary)
- [ ] Uses design system tokens, not ad-hoc values
- [ ] Reuses existing components where possible

> Reference: `docs/design/DESIGN_SYSTEM.md`, `docs/design/COMPONENTS.md`

---

## 7. Documentation Maintenance

Code changes that affect system behavior MUST include documentation updates:

| Change Type                    | Update Target                                              |
|--------------------------------|------------------------------------------------------------|
| Architecture / structure       | `docs/architecture/*.md`                                   |
| Roles / permissions            | `docs/RBAC_GUIDE.md` + `docs/architecture/SECURITY.md`    |
| New features                   | `docs/PRD.md` (relevant sections)                          |
| Configuration additions        | `docs/architecture/CONFIGURATION.md`                       |
| Database schema                | `docs/architecture/DATABASE.md`                            |
| Task progress                  | `docs/tasks/*.md` + `docs/progress/*.md`                   |
| Design system / components     | `docs/design/*.md`                                         |
| Data flows                     | `docs/architecture/DATA_FLOW.md`                           |

**Rule**: do NOT deliver code without updating the affected documentation.
If unsure which docs are affected: list candidates and ask the user.

> Reference: `CLAUDE.md` §9

---

## 8. Regression Prevention

> For regression prevention procedures, see `docs/engineering/TESTING.md` and `docs/engineering/QUALITY_GATES.md`.
