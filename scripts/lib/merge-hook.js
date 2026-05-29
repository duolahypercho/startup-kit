#!/usr/bin/env node
// Idempotently install or remove the startup-kit session-start update hook in an
// agent's JSON config (Cursor hooks.json, Claude Code settings.json, Codex
// hooks.json). Preserves every other key and any hooks we didn't add.
//
// Usage: node merge-hook.js <cursor|claude|codex> <configPath> <command> <install|uninstall>
//
// "ours" entries are identified by the command containing "check-update.sh", so
// re-running install never creates duplicates and uninstall only removes ours.

'use strict';
const fs = require('fs');
const path = require('path');

const [, , agent, configPath, command, mode] = process.argv;

if (!agent || !configPath || !command || !mode) {
  console.error('usage: merge-hook.js <agent> <configPath> <command> <install|uninstall>');
  process.exit(2);
}

function load(p) {
  try {
    const text = fs.readFileSync(p, 'utf8');
    return text.trim() ? JSON.parse(text) : {};
  } catch (err) {
    if (err.code === 'ENOENT') return {};
    throw err;
  }
}

function save(p, obj) {
  fs.mkdirSync(path.dirname(p), { recursive: true });
  fs.writeFileSync(p, JSON.stringify(obj, null, 2) + '\n');
}

function isOurs(entry) {
  return JSON.stringify(entry).includes('check-update.sh');
}

function apply(arr, entry) {
  for (let i = arr.length - 1; i >= 0; i--) {
    if (isOurs(arr[i])) arr.splice(i, 1);
  }
  if (mode === 'install') arr.push(entry);
}

const cfg = load(configPath);
cfg.hooks = cfg.hooks || {};

if (agent === 'cursor') {
  if (cfg.version == null) cfg.version = 1;
  cfg.hooks.sessionStart = cfg.hooks.sessionStart || [];
  apply(cfg.hooks.sessionStart, { command });
} else if (agent === 'claude') {
  cfg.hooks.SessionStart = cfg.hooks.SessionStart || [];
  apply(cfg.hooks.SessionStart, { hooks: [{ type: 'command', command }] });
} else if (agent === 'codex') {
  cfg.hooks.SessionStart = cfg.hooks.SessionStart || [];
  apply(cfg.hooks.SessionStart, { matcher: 'startup|resume', hooks: [{ type: 'command', command }] });
} else {
  console.error(`unknown agent: ${agent}`);
  process.exit(2);
}

for (const key of ['sessionStart', 'SessionStart']) {
  if (Array.isArray(cfg.hooks[key]) && cfg.hooks[key].length === 0) delete cfg.hooks[key];
}
if (cfg.hooks && Object.keys(cfg.hooks).length === 0) delete cfg.hooks;

save(configPath, cfg);
console.log(mode === 'install' ? 'installed' : 'removed');
