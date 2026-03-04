#!/usr/bin/env bash
set -euo pipefail

# ─── Resolve paths relative to this script (location-agnostic) ───────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PKG_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CLI="$PKG_ROOT/bin/cli.js"

PASS=0; FAIL=0; TOTAL=0

assert() {
  TOTAL=$((TOTAL + 1))
  if eval "$1" >/dev/null 2>&1; then
    PASS=$((PASS + 1)); echo "  ✅ $2"
  else
    FAIL=$((FAIL + 1)); echo "  ❌ $2"
  fi
}

# ─── Test 1: Fresh Install ───────────────────────────────────────────────────
test_fresh_install() {
  echo ""
  echo "▶ Test: Fresh Install"
  local dir; dir=$(mktemp -d)

  (cd "$dir" && node "$CLI" install >/dev/null 2>&1)

  assert "test -d '$dir/.agents'"              ".agents/ created"
  assert "test -d '$dir/.claude'"              ".claude/ created"
  assert "test -d '$dir/docs'"                 "docs/ created"
  assert "test -f '$dir/CLAUDE.md'"            "CLAUDE.md created"
  assert "test -f '$dir/.ai-guidelines.json'"  "manifest created"
  assert "test ! -f '$dir/package.json'"       "package.json NOT copied"
  assert "test ! -d '$dir/bin'"                "bin/ NOT copied"
  assert "test ! -d '$dir/tests'"              "tests/ NOT copied"

  rm -rf "$dir"
}

# ─── Test 2: Update preserves customized files ──────────────────────────────
test_update_preserves() {
  echo ""
  echo "▶ Test: Update preserves customizations"
  local dir; dir=$(mktemp -d)

  (cd "$dir" && node "$CLI" install >/dev/null 2>&1)
  echo "# My custom CLAUDE.md" > "$dir/CLAUDE.md"
  (cd "$dir" && node "$CLI" update >/dev/null 2>&1)

  assert "head -1 '$dir/CLAUDE.md' | grep -q 'My custom'" \
    "customized CLAUDE.md preserved"

  rm -rf "$dir"
}

# ─── Test 3: Force overwrite with backup ─────────────────────────────────────
test_force_overwrite() {
  echo ""
  echo "▶ Test: Force overwrite + backup"
  local dir; dir=$(mktemp -d)

  (cd "$dir" && node "$CLI" install >/dev/null 2>&1)
  echo "# My custom CLAUDE.md" > "$dir/CLAUDE.md"
  (cd "$dir" && node "$CLI" update --force >/dev/null 2>&1)

  assert "head -1 '$dir/CLAUDE.md' | grep -q 'Claude Code'" \
    "CLAUDE.md overwritten"
  assert "test -d '$dir/.ai-guidelines-backup'" \
    "backup directory created"

  rm -rf "$dir"
}

# ─── Test 4: Dry run changes nothing ─────────────────────────────────────────
test_dry_run() {
  echo ""
  echo "▶ Test: Dry run"
  local dir; dir=$(mktemp -d)

  (cd "$dir" && node "$CLI" install --dry-run >/dev/null 2>&1)

  assert "test ! -f '$dir/CLAUDE.md'" \
    "no files created on install dry run"

  rm -rf "$dir"
}

# ─── Test 5: Double install fails without --force ────────────────────────────
test_double_install() {
  echo ""
  echo "▶ Test: Double install fails"
  local dir; dir=$(mktemp -d)

  (cd "$dir" && node "$CLI" install >/dev/null 2>&1)

  assert "! (cd '$dir' && node '$CLI' install 2>/dev/null)" \
    "second install rejected"

  rm -rf "$dir"
}

# ─── Test 6: Manifest tracks correct hashes ──────────────────────────────────
test_manifest_integrity() {
  echo ""
  echo "▶ Test: Manifest integrity"
  local dir; dir=$(mktemp -d)

  (cd "$dir" && node "$CLI" install >/dev/null 2>&1)

  assert "node -e \"const m = require('$dir/.ai-guidelines.json'); process.exit(m.version ? 0 : 1)\"" \
    "manifest has version"
  assert "node -e \"const m = require('$dir/.ai-guidelines.json'); process.exit(m.files['CLAUDE.md'] ? 0 : 1)\"" \
    "manifest tracks CLAUDE.md"
  assert "node -e \"const m = require('$dir/.ai-guidelines.json'); process.exit(m.files['CLAUDE.md'].hash.length === 64 ? 0 : 1)\"" \
    "hash is SHA-256 (64 chars)"

  rm -rf "$dir"
}

# ─── Test 7: Help output ────────────────────────────────────────────────────
test_help() {
  echo ""
  echo "▶ Test: Help output"

  assert "node '$CLI' --help 2>&1 | grep -q 'install'" \
    "--help shows install command"
  assert "node '$CLI' --help 2>&1 | grep -q 'update'" \
    "--help shows update command"
}

# ─── Run all tests ───────────────────────────────────────────────────────────
echo "🧪 ai-guidelines CLI — Test Suite"
echo "================================="

test_fresh_install
test_update_preserves
test_force_overwrite
test_dry_run
test_double_install
test_manifest_integrity
test_help

echo ""
echo "================================="
echo "Results: $PASS passed, $FAIL failed, $TOTAL total"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
