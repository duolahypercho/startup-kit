#!/usr/bin/env node
// Resolve a React Bits background (or "all") from the catalog manifest.
// Usage: node bg-resolve.js <manifest.json> <Name|all>
// Prints three lines: files, npm dependencies, resolved names (all space-separated).

const fs = require("fs");

const [, , manifestPath, name] = process.argv;

if (!manifestPath || !name) {
  console.error("Usage: node bg-resolve.js <manifest.json> <Name|all>");
  process.exit(1);
}

const manifest = JSON.parse(fs.readFileSync(manifestPath, "utf8"));
const all = manifest.backgrounds || [];

let list;
if (name.toLowerCase() === "all") {
  list = all;
} else {
  const found = all.find((b) => b.name.toLowerCase() === name.toLowerCase());
  if (!found) {
    console.error(
      `Unknown background "${name}".\nAvailable: ${all.map((b) => b.name).join(", ")}`
    );
    process.exit(2);
  }
  list = [found];
}

const files = [...new Set(list.flatMap((b) => b.files || []))];
const deps = [...new Set(list.flatMap((b) => b.dependencies || []))];
const names = list.map((b) => b.name);

console.log(files.join(" "));
console.log(deps.join(" "));
console.log(names.join(" "));
