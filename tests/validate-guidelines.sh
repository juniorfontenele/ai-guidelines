#!/usr/bin/env bash
set -euo pipefail

# ─── AI Guidelines Validation Tests ──────────────────────────────────────────
# Validates the integrity and consistency of AI guidelines.
# Run: bash tests/validate-guidelines.sh

readonly SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

PASS=0; FAIL=0; TOTAL=0

# ─── Helpers ──────────────────────────────────────────────────────────────────
green()  { echo -e "\033[32m$1\033[0m"; }
red()    { echo -e "\033[31m$1\033[0m"; }
bold()   { echo -e "\033[1m$1\033[0m"; }

assert() {
    TOTAL=$((TOTAL + 1))
    if eval "$1" > /dev/null 2>&1; then
        PASS=$((PASS + 1)); echo "  ✅ $2"
    else
        FAIL=$((FAIL + 1)); echo "  ❌ $2"
    fi
}

section() {
    echo ""
    bold "── $1 ──"
}

# ─── Test 1: Required Files Exist ────────────────────────────────────────────
section "Required Files"

assert "test -f '$ROOT_DIR/CLAUDE.md'" "CLAUDE.md exists"
assert "test -f '$ROOT_DIR/HOW_IT_WORKS.md'" "HOW_IT_WORKS.md exists"
assert "test -f '$ROOT_DIR/CHANGELOG.md'" "CHANGELOG.md exists"
assert "test -f '$ROOT_DIR/CONTRIBUTING.md'" "CONTRIBUTING.md exists"
assert "test -f '$ROOT_DIR/README.md'" "README.md exists"
assert "test -f '$ROOT_DIR/docs/AGENT_FLOW.md'" "AGENT_FLOW.md exists"
assert "test -f '$ROOT_DIR/docs/PRD.md'" "PRD.md exists"
assert "test -f '$ROOT_DIR/docs/engineering/QUALITY_GATES.md'" "QUALITY_GATES.md exists"
assert "test -f '$ROOT_DIR/docs/engineering/TESTING.md'" "TESTING.md exists"
assert "test -f '$ROOT_DIR/docs/engineering/CODE_STANDARDS.md'" "CODE_STANDARDS.md exists"
assert "test -f '$ROOT_DIR/docs/engineering/WORKFLOW.md'" "WORKFLOW.md exists"
assert "test -f '$ROOT_DIR/docs/engineering/STACK.md'" "STACK.md exists"
assert "test -f '$ROOT_DIR/docs/engineering/DEPLOY.md'" "DEPLOY.md exists"

# ─── Test 2: Skill Frontmatter ───────────────────────────────────────────────
section "Skill Frontmatter"

for skill_dir in "$ROOT_DIR"/.agents/skills/*/; do
    skill_name=$(basename "$skill_dir")
    skill_file="$skill_dir/SKILL.md"

    assert "test -f '$skill_file'" "Skill '$skill_name' has SKILL.md"

    if [ -f "$skill_file" ]; then
        # Check for YAML frontmatter
        assert "head -1 '$skill_file' | grep -q '^---'" "Skill '$skill_name' has frontmatter"

        # Check for description in frontmatter
        assert "grep -q '^description:' '$skill_file'" "Skill '$skill_name' has description"
    fi
done

# ─── Test 3: Skill Sync (.agents ↔ .claude) ─────────────────────────────────
section "Skill Sync (.agents ↔ .claude)"

for skill_dir in "$ROOT_DIR"/.agents/skills/*/; do
    skill_name=$(basename "$skill_dir")
    claude_skill="$ROOT_DIR/.claude/skills/$skill_name/SKILL.md"
    agent_skill="$skill_dir/SKILL.md"

    assert "test -f '$claude_skill'" "Skill '$skill_name' mirrored in .claude/"

    if [ -f "$claude_skill" ] && [ -f "$agent_skill" ]; then
        assert "diff -q '$agent_skill' '$claude_skill'" "Skill '$skill_name' content matches"
    fi
done

# ─── Test 4: No Absolute Paths in Markdown ───────────────────────────────────
section "Relative Paths (no absolute system paths)"

# Check for absolute file paths in markdown files (e.g., /home/user/..., /Users/...)
# Exclude node_modules, .git, and known safe patterns
ABS_PATHS=$(find "$ROOT_DIR" -name '*.md' \
    -not -path '*node_modules*' \
    -not -path '*.git*' \
    -not -path '*/.gemini/*' \
    -exec grep -l '/home/\|/Users/\|/tmp/' {} \; 2>/dev/null || true)

assert "test -z '$ABS_PATHS'" "No absolute system paths in .md files"

if [ -n "$ABS_PATHS" ]; then
    echo "    Files with absolute paths:"
    echo "$ABS_PATHS" | while read -r f; do
        echo "      - $(realpath --relative-to="$ROOT_DIR" "$f")"
    done
fi

# ─── Test 5: Workflow Frontmatter ────────────────────────────────────────────
section "Workflow Frontmatter"

for workflow_file in "$ROOT_DIR"/.agents/workflows/*.md; do
    workflow_name=$(basename "$workflow_file" .md)

    # Check for YAML frontmatter
    assert "head -1 '$workflow_file' | grep -q '^---'" "Workflow '$workflow_name' has frontmatter"

    # Check for description
    assert "grep -q '^description:' '$workflow_file'" "Workflow '$workflow_name' has description"
done

# ─── Test 6: Rules Frontmatter ───────────────────────────────────────────────
section "Rules Frontmatter"

for rule_file in "$ROOT_DIR"/.agents/rules/*.md; do
    rule_name=$(basename "$rule_file" .md)

    assert "head -1 '$rule_file' | grep -q '^---'" "Rule '$rule_name' has frontmatter"
    assert "grep -q '^trigger:' '$rule_file'" "Rule '$rule_name' has trigger"
done

# ─── Test 7: No Stub Files ──────────────────────────────────────────────────
section "No Empty Stubs"

for doc_file in "$ROOT_DIR"/docs/engineering/*.md; do
    doc_name=$(basename "$doc_file")
    line_count=$(wc -l < "$doc_file")
    assert "test $line_count -gt 5" "Doc '$doc_name' is not a stub ($line_count lines)"
done

# ─── Results ─────────────────────────────────────────────────────────────────
echo ""
bold "═══════════════════════════════════════════"
if [ "$FAIL" -eq 0 ]; then
    green "  All tests passed: $PASS/$TOTAL ✅"
else
    red "  $FAIL tests failed out of $TOTAL"
fi
bold "═══════════════════════════════════════════"
echo ""

[ "$FAIL" -eq 0 ] && exit 0 || exit 1
