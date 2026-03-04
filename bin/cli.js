#!/usr/bin/env node

"use strict";

const fs = require("fs");
const path = require("path");
const crypto = require("crypto");

// ─── Constants ──────────────────────────────────────────────────────────────────

const MANIFEST_FILE = ".ai-guidelines.json";
const BACKUP_DIR = ".ai-guidelines-backup";
const PKG_ROOT = path.resolve(__dirname, "..");

/** Directories/files to copy from the package to the target project */
const DISTRIBUTABLE = [".agents", ".claude", "docs", "CLAUDE.md"];

/** Files/dirs that should NEVER be copied even if inside distributable dirs */
const EXCLUDE = [".git", "node_modules", ".DS_Store", "Thumbs.db"];

// ─── Colors (ANSI, no dependencies) ─────────────────────────────────────────────

const c = {
  reset: "\x1b[0m",
  bold: "\x1b[1m",
  dim: "\x1b[2m",
  green: "\x1b[32m",
  yellow: "\x1b[33m",
  red: "\x1b[31m",
  cyan: "\x1b[36m",
  blue: "\x1b[34m",
};

// ─── Utilities ──────────────────────────────────────────────────────────────────

function hashFile(filePath) {
  const content = fs.readFileSync(filePath);
  return crypto.createHash("sha256").update(content).digest("hex");
}

function getAllFiles(dir, base = "") {
  const entries = [];
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    if (EXCLUDE.includes(entry.name)) continue;
    const rel = base ? path.join(base, entry.name) : entry.name;
    if (entry.isDirectory()) {
      entries.push(...getAllFiles(path.join(dir, entry.name), rel));
    } else {
      entries.push(rel);
    }
  }
  return entries;
}

function getSourceFiles() {
  const files = [];
  for (const item of DISTRIBUTABLE) {
    const src = path.join(PKG_ROOT, item);
    if (!fs.existsSync(src)) continue;
    if (fs.statSync(src).isDirectory()) {
      files.push(...getAllFiles(src, item));
    } else {
      files.push(item);
    }
  }
  return files;
}

function ensureDir(filePath) {
  const dir = path.dirname(filePath);
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
}

function copyFile(src, dest) {
  ensureDir(dest);
  fs.copyFileSync(src, dest);
}

function readManifest(targetDir) {
  const manifestPath = path.join(targetDir, MANIFEST_FILE);
  if (!fs.existsSync(manifestPath)) return null;
  return JSON.parse(fs.readFileSync(manifestPath, "utf8"));
}

function writeManifest(targetDir, manifest) {
  const manifestPath = path.join(targetDir, MANIFEST_FILE);
  fs.writeFileSync(manifestPath, JSON.stringify(manifest, null, 2) + "\n");
}

function generateManifest(targetDir, files) {
  const pkg = JSON.parse(
    fs.readFileSync(path.join(PKG_ROOT, "package.json"), "utf8"),
  );
  const manifest = {
    version: pkg.version,
    installedAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
    files: {},
  };
  for (const file of files) {
    const filePath = path.join(targetDir, file);
    if (fs.existsSync(filePath)) {
      manifest.files[file] = { hash: hashFile(filePath) };
    }
  }
  return manifest;
}

// ─── Commands ───────────────────────────────────────────────────────────────────

function install(targetDir, flags) {
  const manifest = readManifest(targetDir);

  if (manifest && !flags.force) {
    console.error(
      `${c.red}✖${c.reset} Guidelines already installed (v${manifest.version}, ${manifest.installedAt}).`,
    );
    console.error(
      `  Use ${c.cyan}ai-guidelines install --force${c.reset} to overwrite.`,
    );
    process.exit(1);
  }

  const files = getSourceFiles();

  if (flags.dryRun) {
    console.log(`\n${c.bold}📦 Dry run — install${c.reset}\n`);
    console.log(
      `  Would copy ${c.cyan}${files.length}${c.reset} files to ${c.dim}${targetDir}${c.reset}\n`,
    );
    for (const file of files) {
      console.log(`  ${c.green}+ ${file}${c.reset}`);
    }
    console.log(`\n  ${c.dim}No changes made.${c.reset}\n`);
    return;
  }

  console.log(`\n${c.bold}📦 Installing ai-guidelines...${c.reset}\n`);

  let copied = 0;
  for (const file of files) {
    const src = path.join(PKG_ROOT, file);
    const dest = path.join(targetDir, file);
    copyFile(src, dest);
    copied++;
  }

  const newManifest = generateManifest(targetDir, files);
  writeManifest(targetDir, newManifest);

  console.log(`  ${c.green}✔${c.reset} ${copied} files installed`);
  console.log(`  ${c.green}✔${c.reset} Manifest created (${MANIFEST_FILE})\n`);
  console.log(`${c.bold}Next steps:${c.reset}`);
  console.log(`  1. Open your AI assistant (Antigravity or Claude Code)`);
  console.log(
    `  2. Run ${c.cyan}/init-project${c.reset} to customize the guidelines`,
  );
  console.log("");
}

function update(targetDir, flags) {
  const manifest = readManifest(targetDir);

  if (!manifest) {
    console.error(
      `${c.red}✖${c.reset} No guidelines found. Run ${c.cyan}ai-guidelines install${c.reset} first.`,
    );
    process.exit(1);
  }

  const sourceFiles = getSourceFiles();
  const pkg = JSON.parse(
    fs.readFileSync(path.join(PKG_ROOT, "package.json"), "utf8"),
  );

  const results = {
    added: [],
    updated: [],
    skipped: [],
    conflicts: [],
    orphaned: [],
  };

  // Classify each source file
  for (const file of sourceFiles) {
    const src = path.join(PKG_ROOT, file);
    const dest = path.join(targetDir, file);
    const upstreamHash = hashFile(src);
    const manifestEntry = manifest.files[file];

    if (!manifestEntry) {
      // New file — not in manifest
      if (fs.existsSync(dest)) {
        // File exists locally but wasn't tracked — treat as conflict
        results.conflicts.push({
          file,
          reason: "exists locally but not in manifest",
        });
      } else {
        results.added.push(file);
      }
      continue;
    }

    const manifestHash = manifestEntry.hash;

    if (!fs.existsSync(dest)) {
      // User deleted the file — re-add from upstream
      results.added.push(file);
      continue;
    }

    const localHash = hashFile(dest);

    if (localHash === upstreamHash) {
      // Identical — nothing to do
      results.skipped.push(file);
      continue;
    }

    const localModified = localHash !== manifestHash;
    const upstreamModified = upstreamHash !== manifestHash;

    if (!localModified && upstreamModified) {
      // User didn't change it, upstream did → safe update
      results.updated.push(file);
    } else if (localModified && !upstreamModified) {
      // User changed it, upstream didn't → skip
      results.skipped.push(file);
    } else if (localModified && upstreamModified) {
      // Both changed → conflict
      results.conflicts.push({ file, reason: "modified locally and upstream" });
    } else {
      results.skipped.push(file);
    }
  }

  // Check for orphaned files (in manifest but not in upstream)
  for (const file of Object.keys(manifest.files)) {
    if (!sourceFiles.includes(file)) {
      results.orphaned.push(file);
    }
  }

  // ─── Dry run ───
  if (flags.dryRun) {
    printReport(results, true);
    return;
  }

  // ─── Force mode: backup + overwrite all ───
  if (flags.force) {
    const conflictsAndSkipped = [
      ...results.conflicts.map((c) => c.file),
      ...results.skipped.filter((f) => {
        const dest = path.join(targetDir, f);
        if (!fs.existsSync(dest)) return false;
        const localHash = hashFile(dest);
        const manifestEntry = manifest.files[f];
        return manifestEntry && localHash !== manifestEntry.hash;
      }),
    ];

    if (conflictsAndSkipped.length > 0) {
      const backupDir = path.join(targetDir, BACKUP_DIR);
      const timestamp = new Date().toISOString().replace(/[:.]/g, "-");
      const backupPath = path.join(backupDir, timestamp);

      for (const file of conflictsAndSkipped) {
        const dest = path.join(targetDir, file);
        if (fs.existsSync(dest)) {
          const backupFile = path.join(backupPath, file);
          ensureDir(backupFile);
          fs.copyFileSync(dest, backupFile);
        }
      }

      console.log(
        `\n  ${c.yellow}⚠${c.reset}  Backup saved to ${c.dim}${backupPath}${c.reset}`,
      );
    }

    // Force: overwrite conflicts too
    for (const { file } of results.conflicts) {
      results.updated.push(file);
    }
    results.conflicts = [];

    // Force: overwrite user-modified skipped files
    const userModifiedSkipped = results.skipped.filter((f) => {
      const dest = path.join(targetDir, f);
      if (!fs.existsSync(dest)) return false;
      const localHash = hashFile(dest);
      const manifestEntry = manifest.files[f];
      return manifestEntry && localHash !== manifestEntry.hash;
    });
    for (const file of userModifiedSkipped) {
      results.updated.push(file);
      results.skipped = results.skipped.filter((f) => f !== file);
    }
  }

  // ─── Apply changes ───
  for (const file of results.added) {
    const src = path.join(PKG_ROOT, file);
    const dest = path.join(targetDir, file);
    copyFile(src, dest);
  }

  for (const file of results.updated) {
    const src = path.join(PKG_ROOT, file);
    const dest = path.join(targetDir, file);
    copyFile(src, dest);
  }

  // ─── Update manifest ───
  const newManifest = {
    ...manifest,
    updatedAt: new Date().toISOString(),
    version: pkg.version,
  };

  for (const file of [...results.added, ...results.updated]) {
    const dest = path.join(targetDir, file);
    newManifest.files[file] = { hash: hashFile(dest) };
  }

  // Remove orphaned entries from manifest
  for (const file of results.orphaned) {
    delete newManifest.files[file];
  }

  writeManifest(targetDir, newManifest);

  printReport(results, false);

  if (flags.diff && results.conflicts.length > 0) {
    printDiffs(targetDir, results.conflicts);
  }
}

// ─── Output ─────────────────────────────────────────────────────────────────────

function printReport(results, dryRun) {
  const prefix = dryRun
    ? `\n${c.bold}📦 Dry run — update${c.reset}\n`
    : `\n${c.bold}📦 Update complete${c.reset}\n`;
  console.log(prefix);

  if (results.added.length > 0) {
    console.log(`  ${c.green}Added (${results.added.length}):${c.reset}`);
    for (const f of results.added)
      console.log(`    ${c.green}+ ${f}${c.reset}`);
  }

  if (results.updated.length > 0) {
    console.log(`  ${c.blue}Updated (${results.updated.length}):${c.reset}`);
    for (const f of results.updated)
      console.log(`    ${c.blue}↑ ${f}${c.reset}`);
  }

  if (results.conflicts.length > 0) {
    console.log(
      `  ${c.yellow}Conflicts (${results.conflicts.length}):${c.reset}`,
    );
    for (const { file } of results.conflicts)
      console.log(`    ${c.yellow}⚠ ${file}${c.reset}`);
  }

  if (results.orphaned.length > 0) {
    console.log(`  ${c.dim}Orphaned (${results.orphaned.length}):${c.reset}`);
    for (const f of results.orphaned)
      console.log(`    ${c.dim}? ${f}${c.reset}`);
  }

  const unchanged = results.skipped.length;
  if (unchanged > 0) {
    console.log(`  ${c.dim}Unchanged: ${unchanged} files${c.reset}`);
  }

  console.log("");

  if (results.conflicts.length > 0) {
    console.log(
      `  ${c.yellow}Tip:${c.reset} Use ${c.cyan}ai-guidelines update --diff${c.reset} to see upstream changes`,
    );
    console.log(
      `       Use ${c.cyan}ai-guidelines update --force${c.reset} to overwrite (with backup)\n`,
    );
  }

  if (dryRun) {
    console.log(`  ${c.dim}No changes made.${c.reset}\n`);
  }
}

function printDiffs(targetDir, conflicts) {
  console.log(
    `\n${c.bold}📝 Upstream changes for conflicting files:${c.reset}\n`,
  );

  for (const { file } of conflicts) {
    const src = path.join(PKG_ROOT, file);
    const dest = path.join(targetDir, file);

    console.log(`${c.bold}── ${file} ──${c.reset}`);
    console.log(`  ${c.dim}Local:    ${dest}${c.reset}`);
    console.log(`  ${c.dim}Upstream: ${src}${c.reset}\n`);
  }
}

// ─── Help ───────────────────────────────────────────────────────────────────────

function showHelp() {
  console.log(`
${c.bold}@juniorfontenele/ai-guidelines${c.reset} — AI development guidelines installer

${c.bold}Usage:${c.reset}
  npx @juniorfontenele/ai-guidelines <command> [options]

${c.bold}Commands:${c.reset}
  ${c.cyan}install${c.reset}    Copy guideline files to the current project
  ${c.cyan}update${c.reset}     Update guidelines without overwriting customizations

${c.bold}Options:${c.reset}
  ${c.dim}--force${c.reset}     Overwrite all files (backs up modified files)
  ${c.dim}--diff${c.reset}      Show upstream changes for conflicting files
  ${c.dim}--dry-run${c.reset}   Preview changes without modifying any files
  ${c.dim}--help${c.reset}      Show this help message

${c.bold}Examples:${c.reset}
  ${c.dim}# First-time install${c.reset}
  npx @juniorfontenele/ai-guidelines install

  ${c.dim}# Update (preserves your changes)${c.reset}
  npx @juniorfontenele/ai-guidelines update

  ${c.dim}# See what would change${c.reset}
  npx @juniorfontenele/ai-guidelines update --dry-run

  ${c.dim}# Force update with backup${c.reset}
  npx @juniorfontenele/ai-guidelines update --force

${c.bold}After installing:${c.reset}
  Open your AI assistant and run ${c.cyan}/init-project${c.reset} to customize.
`);
}

// ─── Main ───────────────────────────────────────────────────────────────────────

function main() {
  const args = process.argv.slice(2);
  const command = args.find((a) => !a.startsWith("-"));
  const flags = {
    force: args.includes("--force"),
    dryRun: args.includes("--dry-run"),
    diff: args.includes("--diff"),
    help: args.includes("--help") || args.includes("-h"),
  };

  if (flags.help || !command) {
    showHelp();
    process.exit(0);
  }

  const targetDir = process.cwd();

  switch (command) {
    case "install":
      install(targetDir, flags);
      break;
    case "update":
      update(targetDir, flags);
      break;
    default:
      console.error(`${c.red}✖${c.reset} Unknown command: ${command}`);
      console.error(`  Run ${c.cyan}ai-guidelines --help${c.reset} for usage.`);
      process.exit(1);
  }
}

main();
