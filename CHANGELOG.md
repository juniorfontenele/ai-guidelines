# Changelog

All notable changes to `@juniorfontenele/ai-guidelines` will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Versioning Policy

- **MAJOR**: Breaking changes to existing skills/workflows, directory structure changes, skill removals
- **MINOR**: New skills, workflows, documentation, CLI features
- **PATCH**: Bug fixes, reference corrections, typos

---

## [Unreleased]

### Added

- `HOW_IT_WORKS.md` — Meta-documentation for AI agents
- `CHANGELOG.md` — This file
- `CONTRIBUTING.md` — Contribution guide
- `/generate-commit-message` workflow
- `stack-bash` skill (Bash/Shell development patterns)
- `database-migration` skill (migration planning and execution)
- `api-development` skill (RESTful API patterns)
- Skill composition mechanism (`dependencies` in frontmatter)
- Guidelines validation tests (`tests/validate-guidelines.sh`)
- Monorepo detection in `init-project`
- Locale system (configurable via `init-project`)
- Fast path for trivial tasks in `00-bootstrap.md`
- §5 "Skill vs Workflow Disambiguation" section in `AGENT_FLOW.md`

### Changed

- `QUALITY_GATES.md` — Consolidated from 5 sources into single canonical doc with 4 gates
- `AGENT_FLOW.md` — Removed duplicate "Refatorar" routing, added disambiguation
- `CLAUDE.md` — §2 and §6 now reference canonical sources
- `WORKFLOW.md` — AI-Assisted section now references `AGENT_FLOW.md`
- `implement-task` — §4 references `QUALITY_GATES.md`, skill modularized into sub-references
- `init-project` — Replaced Rust with Bash detection, added monorepo and locale support
- `code-review.md` — Branch reference unified to `master`
- `PRD.md` — Added PRD strategy note (main vs feature PRDs)
- `00-bootstrap.md` — Fixed §references, added fast path
- `01-quality-shield.md` — Fixed §10 reference, added conditional notes for API-only
- Rules now adaptable for API-only projects

### Removed

- `.claude/settings.local.json` — Moved to `.gitignore` (template only)
- Duplicated quality gate content from `AGENT_FLOW.md`, `CLAUDE.md`, and `implement-task`
- Duplicated pipeline content from `WORKFLOW.md`
- Rust detection from `init-project`

## [1.0.0] - 2026-03-04

### Added

- Initial release with 23 skills, 13 workflows, 3 rules
- CLI installer (`npx @juniorfontenele/ai-guidelines install/update`)
- Full development pipeline: brainstorming → PRD → architecture → UI → tasks → implementation
- Stack packs: Node.js, Python, Go
- Quality gates: Lint, Test, Security
- Engineering docs: CODE_STANDARDS, TESTING, WORKFLOW, QUALITY_GATES, STACK, DATABASE_PATTERNS
