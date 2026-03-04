---
description: Show current project development status — progress tracking, active branch, pending tasks, and quality gate state. Use to get a quick overview of where the project stands.
---

# Project Status

## Steps

1. Read progress tracking:
   // turbo
   - Read `docs/progress/README.md` for the overall dashboard
   - Count tasks by status: `TODO`, `IN_PROGRESS`, `DONE`, `BLOCKED`
   - Calculate completion percentage per epic

2. Check current git state:
   // turbo
   - Current branch: `git branch --show-current`
   - Uncommitted changes: `git status --short`
   - Recent commits: `git log --oneline -5`

3. Find tasks in progress:
   - Search `docs/progress/` for any `IN_PROGRESS` entries
   - List them with their epic and start date

4. List next tasks:
   - Find the next 3 `TODO` tasks from `docs/tasks/`
   - Show their IDs, names, and dependencies

5. Quick quality check:
   // turbo
   - Run `composer lint 2>&1 | tail -5` (or equivalent for detected stack)
   - Report: passing or failing

6. Present summary to the user:

   ```
   ## 📊 Project Status

   ### Progress
   | Epic | Done | Total | % |
   | ...  | ...  | ...   | . |

   ### Current Work
   - Branch: `feat/...`
   - In Progress: [task list]
   - Uncommitted: [count] files

   ### Next Up
   1. [TASK-ID] — Description
   2. [TASK-ID] — Description

   ### Quality Gates
   - Lint: ✅/❌
   ```
