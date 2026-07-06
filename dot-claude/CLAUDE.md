# Global instructions

## mcpipe

mcpipe is installed via pipx and runs as the local MCP server (`mcpipe server`).
It keeps CLI output out of the context window — tools return a handle, you read with `view`.

```
git_log(since="1week")  →  { handle: "git_log_...", lines: 847, preview: "..." }
view(handle="...", _search="auth")  →  matching lines only
```

**Always prefer mcpipe tools** (git_*, fs_*, docker_*, compose_*) over raw Bash equivalents
when they're available — they keep output out of the context window.

CLI: `mcpipe list`, `mcpipe run <tool>`, `mcpipe view <handle>`, `mcpipe approve`

### Feedback

David Kristiansen is the **author** of mcpipe. Whenever you notice a bug, papercut, or
improvement idea — even incidental to the current task — use the `mcpipe-feedback` skill
to log it in `~/src/mcpipe/mcpipe-feedback.md`. Do not silently ignore it.
# graphify
- **graphify** (`~/.claude/skills/graphify/SKILL.md`) - any input to knowledge graph. Trigger: `/graphify`
When the user types `/graphify`, invoke the Skill tool with `skill: "graphify"` before doing anything else.

## graphify → Obsidian vault sync (do this automatically)
I keep one unified Obsidian vault at `~/.local/share/vault` (Johnny Decimal). graphify graphs are integrated into it under a quarantined, machine-owned subfolder per project: `~/.local/share/vault/graphify/<project>/` (where `<project>` is the repo dir's basename).

The graphify CLI does NOT remember a vault target — `--obsidian-dir` is per-invocation only, and `graphify update`/`extract` have no obsidian flag. So **you (Claude) must refresh the export yourself**: whenever you build, rebuild, `--update`, or `update --force` a graphify graph for a project, follow it with:
```sh
graphify export obsidian --dir "$HOME/.local/share/vault/graphify/<project>/"
```
Rules:
- Never dump node files loose into the vault root or into Johnny Decimal areas — only into `graphify/<project>/`. The generic auto-generated filenames (Architecture.md, README.md, …) would shadow curated notes and break `[[links]]`.
- Treat `graphify/<project>/` as regenerable; never hand-edit inside it.
- Keep a thin curated "doorway" note in the JD structure (e.g. `31 Build Tools/`) that links into the export with full vault-relative paths like `[[graphify/<project>/...]]`. Create it on first sync if missing; otherwise leave it alone.
- This keeps everything cross-referenceable in one vault (graph view + search span curated notes and the code graph).

## graphify MCP server — first-build gotcha
The user-scoped `graphify-mcp` server auto-detects `./graphify-out/graph.json` from the session cwd, but it **hard-exits if that file doesn't exist at launch** (it won't lazy-load). Consequences:
- A brand-new repo with no graph yet → MCP server fails to start that session. After building a graph there, the session must be **reloaded** before the server connects. This is one-time per repo; once `graph.json` exists it connects on every later session.
- In any repo you never graphify, the global server just shows "failed" — harmless (tools absent), `/graphify` still works via the CLI.

So the FIRST time we build a graph in a new repo: **let `/graphify` fully finish (wait for `graph.json` to be written — the slow step is semantic extraction) before reloading**, then tell the user to reload so the MCP server picks it up. Don't reload mid-build. If a build was interrupted and left no `graph.json`, `graphify update . --force` writes a fast code-only graph to unblock the server.
