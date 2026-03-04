#!/usr/bin/env bash
set -euo pipefail

# ─── AI Guidelines Validation Tests ──────────────────────────────────────────
# Validates the integrity and consistency of AI guidelines.
# Run: bash tests/validate-guidelines.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly SCRIPT_DIR
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
readonly ROOT_DIR

PASS=0; FAIL=0; TOTAL=0

# ─── Helpers ──────────────────────────────────────────────────────────────────
green()  { echo -e "\033[32m$1\033[0m"; }
red()    { echo -e "\033[31m$1\033[0m"; }
bold()   { echo -e "\033[1m$1\033[0m"; }

assert() {
    local description="$1"
    shift
    TOTAL=$((TOTAL + 1))
    if "$@" > /dev/null 2>&1; then
        PASS=$((PASS + 1)); echo "  ✅ $description"
    else
        FAIL=$((FAIL + 1)); echo "  ❌ $description"
    fi
}

section() {
    echo ""
    bold "── $1 ──"
}

# ─── Test 1: Required Files Exist ────────────────────────────────────────────
section "Required Files"

assert "CLAUDE.md exists" test -f "$ROOT_DIR/CLAUDE.md"
assert "HOW_IT_WORKS.md exists" test -f "$ROOT_DIR/HOW_IT_WORKS.md"
assert "CHANGELOG.md exists" test -f "$ROOT_DIR/CHANGELOG.md"
assert "CONTRIBUTING.md exists" test -f "$ROOT_DIR/CONTRIBUTING.md"
assert "README.md exists" test -f "$ROOT_DIR/README.md"
assert "AGENT_FLOW.md exists" test -f "$ROOT_DIR/docs/AGENT_FLOW.md"
assert "PRD.md exists" test -f "$ROOT_DIR/docs/PRD.md"
assert "QUALITY_GATES.md exists" test -f "$ROOT_DIR/docs/engineering/QUALITY_GATES.md"
assert "TESTING.md exists" test -f "$ROOT_DIR/docs/engineering/TESTING.md"
assert "CODE_STANDARDS.md exists" test -f "$ROOT_DIR/docs/engineering/CODE_STANDARDS.md"
assert "WORKFLOW.md exists" test -f "$ROOT_DIR/docs/engineering/WORKFLOW.md"
assert "STACK.md exists" test -f "$ROOT_DIR/docs/engineering/STACK.md"
assert "DEPLOY.md exists" test -f "$ROOT_DIR/docs/engineering/DEPLOY.md"

# ─── Test 2: Skill Frontmatter ───────────────────────────────────────────────
section "Skill Frontmatter"

for skill_dir in "$ROOT_DIR"/.agents/skills/*/; do
    skill_name=$(basename "$skill_dir")
    skill_file="$skill_dir/SKILL.md"

    assert "Skill '$skill_name' has SKILL.md" test -f "$skill_file"

    if [ -f "$skill_file" ]; then
        assert "Skill '$skill_name' has frontmatter" head -1 "$skill_file"
        assert "Skill '$skill_name' has description" grep -q '^description:' "$skill_file"
    fi
done

# ─── Test 3: Skill Sync (.agents ↔ .claude) ─────────────────────────────────
section "Skill Sync (.agents ↔ .claude)"

for skill_dir in "$ROOT_DIR"/.agents/skills/*/; do
    skill_name=$(basename "$skill_dir")
    claude_skill="$ROOT_DIR/.claude/skills/$skill_name/SKILL.md"
    agent_skill="$skill_dir/SKILL.md"

    assert "Skill '$skill_name' mirrored in .claude/" test -f "$claude_skill"

    if [ -f "$claude_skill" ] && [ -f "$agent_skill" ]; then
        assert "Skill '$skill_name' content matches" diff -q "$agent_skill" "$claude_skill"
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

assert "No absolute system paths in .md files" test -z "$ABS_PATHS"

if [ -n "$ABS_PATHS" ]; then
    echo "    Files with absolute paths:"
    echo "$ABS_PATHS" | while IFS= read -r f; do
        rel_path="${f#"$ROOT_DIR"/}"
        echo "      - $rel_path"
    done
fi

# ─── Test 5: Workflow Frontmatter ────────────────────────────────────────────
section "Workflow Frontmatter"

for workflow_file in "$ROOT_DIR"/.agents/workflows/*.md; do
    workflow_name=$(basename "$workflow_file" .md)

    assert "Workflow '$workflow_name' has frontmatter" head -1 "$workflow_file"
    assert "Workflow '$workflow_name' has description" grep -q '^description:' "$workflow_file"
done

# ─── Test 6: Rules Frontmatter ───────────────────────────────────────────────
section "Rules Frontmatter"

for rule_file in "$ROOT_DIR"/.agents/rules/*.md; do
    rule_name=$(basename "$rule_file" .md)

    assert "Rule '$rule_name' has frontmatter" head -1 "$rule_file"
    assert "Rule '$rule_name' has trigger" grep -q '^trigger:' "$rule_file"
done

# ─── Test 7: No Stub Files ──────────────────────────────────────────────────
section "No Empty Stubs"

for doc_file in "$ROOT_DIR"/docs/engineering/*.md; do
    doc_name=$(basename "$doc_file")
    line_count=$(wc -l < "$doc_file")
    assert "Doc '$doc_name' is not a stub ($line_count lines)" test "$line_count" -gt 5
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
