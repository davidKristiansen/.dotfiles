#!/usr/bin/env node

// SPDX-License-Identifier: MIT
// Copyright David Kristiansen

// PreToolUse gate for the Agent and Workflow tools. It blocks a dispatch that
// leaves the model implicit, because an unstated model always resolves to the
// session model, and that is the most expensive option.
import fs from "node:fs";
import path from "node:path";
import os from "node:os";

const GUIDANCE =
  "First check which dispatch targets this machine has, local and external. " +
  "Then pick the cheapest target that can do the task. " +
  "You can inherit the session model, but you must state that choice.";

// A missing or broken payload leaves nothing to judge, so the gate opens.
let input = {};
try {
  input = JSON.parse(fs.readFileSync(0, "utf8"));
} catch {
  process.exit(0);
}

const call = input.tool_input ?? {};
const tool = String(input.tool_name ?? "");

const block = (message) => {
  console.error(`${message} ${GUIDANCE}`);
  process.exit(2);
};

if (tool === "Workflow") {
  let text = typeof call.script === "string" ? call.script : null;
  if (text === null && typeof call.scriptPath === "string") {
    try {
      text = fs.readFileSync(call.scriptPath, "utf8");
    } catch {
      text = null;
    }
  }
  if (text === null) process.exit(0);

  // One textual agent( site can fan out to many agents, so a single stated
  // choice covers it. A second site needs its own.
  const sites = (text.match(/\bagent\s*\(/g) ?? []).length;
  if (sites === 0) process.exit(0);

  // The lookbehind drops model in a string or in a longer identifier. A
  // `// model: inherit` comment counts, which makes inheritance explicit.
  const stated = (text.match(/(?<!["'\w])model\s*:/g) ?? []).length;
  if (stated < sites) {
    block(
      "This workflow script leaves a model choice unstated. " +
        `Call sites: ${sites}. Stated choices: ${stated}. ` +
        "Set opts.model at each site, or mark the site with a `// model: inherit` comment.",
    );
  }
  process.exit(0);
}

if (tool !== "Agent" && tool !== "Task") process.exit(0);

const type = String(call.subagent_type ?? "");

// A fork always runs on the parent model and ignores a model override.
if (type === "fork") process.exit(0);
// A plugin agent carries its own definition outside these directories.
if (type.includes(":")) process.exit(0);

if (call.model) process.exit(0);

const wanted = `${type}.md`;
const projectRoot = process.env.CLAUDE_PROJECT_DIR ?? input.cwd ?? ".";
const roots = [
  path.join(os.homedir(), ".claude", "agents"),
  path.join(projectRoot, ".claude", "agents"),
];

const findDef = (dir) => {
  let entries;
  try {
    entries = fs.readdirSync(dir, { withFileTypes: true });
  } catch {
    return null;
  }
  for (const entry of entries) {
    const full = path.join(dir, entry.name);
    if (entry.isFile()) {
      if (entry.name === wanted) return full;
    } else if (entry.isDirectory()) {
      const hit = findDef(full);
      if (hit) return hit;
    }
  }
  return null;
};

const definesModel = (file) => {
  let body;
  try {
    body = fs.readFileSync(file, "utf8");
  } catch {
    return false;
  }
  const frontmatter = body.match(/^---\r?\n([\s\S]*?)\r?\n---/);
  return frontmatter !== null && /^model\s*:\s*\S/m.test(frontmatter[1]);
};

const def = roots.map(findDef).find(Boolean) ?? null;

if (def === null) {
  const named = type === "" ? "This call names no subagent type" : `The subagent type "${type}" has no definition file`;
  block(`${named}, so the agent inherits the session model. Set model on the call.`);
}

if (!definesModel(def)) {
  block(`The definition ${def} names no model, so the choice is yours. Set model on this call.`);
}
