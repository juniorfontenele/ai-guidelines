# Changelog

All notable changes to `@juniorfontenele/ai-guidelines` will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Versioning Policy

- **MAJOR**: Breaking changes to existing skills/workflows, directory structure changes, skill removals
- **MINOR**: New skills, workflows, documentation, CLI features
- **PATCH**: Bug fixes, reference corrections, typos

---

## [1.1.0](https://github.com/juniorfontenele/ai-guidelines/compare/v1.0.0...v1.1.0) (2026-03-05)


### Features

* add mandatory cross-cutting gates and /i18n workflow ([c9f6ae5](https://github.com/juniorfontenele/ai-guidelines/commit/c9f6ae5a8c97ad0a9a833b378f2874e775f0615a))
* add orchestrator, UI/UX, debug, refactor, test, docs workflows ([6364543](https://github.com/juniorfontenele/ai-guidelines/commit/6364543e38573be1daa8b753c00fd00e0afe451c))
* add workflows, stack packs, AGENT_FLOW, and automation scripts ([6200594](https://github.com/juniorfontenele/ai-guidelines/commit/6200594a964ae83d837e2a9493911d931337ed65))
* **cli:** add npx installer/updater with smart merge ([94b8f23](https://github.com/juniorfontenele/ai-guidelines/commit/94b8f2362e814459b8db47f86a2d04109bdfdb5e))
* consolidate guidelines, add new skills/workflows, and improve system architecture ([013323d](https://github.com/juniorfontenele/ai-guidelines/commit/013323dfe51d16723ede9a81c8c442b24a97c436))
* consolidate guidelines, add new skills/workflows, and improve system architecture ([e53d13d](https://github.com/juniorfontenele/ai-guidelines/commit/e53d13d34bae0a7faa64cb419fbe78fd36c5f6da))


### Bug Fixes

* address CodeRabbit review feedback on PR [#2](https://github.com/juniorfontenele/ai-guidelines/issues/2) ([cd452e5](https://github.com/juniorfontenele/ai-guidelines/commit/cd452e59d673fbd3fc3c1506075a7bb220e7d119))
* address CodeRabbit round 3 findings ([bbb69ac](https://github.com/juniorfontenele/ai-guidelines/commit/bbb69ac8f824f442d8e4a7928155c2ee59eb9dfe))
* use explicit string comparison for release_created output ([9517806](https://github.com/juniorfontenele/ai-guidelines/commit/9517806ce0c94df37f57704b1cdbc00bbaeaf7ec))


### Refactoring

* generalize rules and fix CodeRabbit round 2 issues ([9a05c2c](https://github.com/juniorfontenele/ai-guidelines/commit/9a05c2c2185accec8dbfe0e3f4967fff1abb6cc8))
* transform repository into agnostic AI development guidelines template ([f75bee2](https://github.com/juniorfontenele/ai-guidelines/commit/f75bee2f3477d4a4bd5879043f7a985df130066c))

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
