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
to log it in `~/src/10.priv/mcpipe/mcpipe-feedback.md`. Do not silently ignore it.
# graphify
- **graphify** (`~/.claude/skills/graphify/SKILL.md`) - any input to knowledge graph. Trigger: `/graphify`
When the user types `/graphify`, invoke the Skill tool with `skill: "graphify"` before doing anything else.

## When to reach for graphify (do this automatically)
Detection: a graph exists for the current project iff `graphify-out/graph.json` is present in the repo root.

- **If a graph exists → use it first for codebase-understanding work.** Architecture questions, "how does X work", file/symbol relationships, "where is this used", impact / blast-radius analysis — query the graph *before* falling back to grep/read fan-out. Prefer the `graphify` MCP tools when connected (`query_graph`, `get_neighbors`, `god_nodes`, `shortest_path`, `get_pr_impact`, …); if the MCP server didn't connect this session (see the first-build gotcha below), use the `/graphify` skill via the CLI.
  - This does **not** apply to trivial, well-scoped edits (a known one-liner, a rename in a file you already have open) — don't spin up graph queries as busywork.
  - Graphs can go stale. If the code has clearly moved on from the graph, say so and offer to refresh with `graphify update . --force` (then re-export to the vault per the sync rules below).
- **If no graph exists → suggest creating one when the task would benefit** (any substantial exploration, onboarding to an unfamiliar area, multi-file refactor planning). Offer, don't auto-build — semantic extraction is slow, so let the user opt in before running `/graphify`.

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
# Neovim via nvim-mcp

The user edits code in Neovim. You control it through the tools of the
`nvim` MCP server. You already know Vim — use that knowledge.

The server runs with `--connect auto`, so it finds and connects to the
Neovim instances of the current project by itself.

## Rules

**⚠ CRITICAL: read the editor state at the START of every turn — call
`list_buffers` and `cursor_position` before any edit or any tool call that
depends on what the user has open. Never carry a buffer ID, a cursor
position, or a file identity over from a previous turn.**

Every tool except `get_targets`, `connect`, and `connect_tcp` needs a
`connection_id`:

1. Read the `nvim-connections://` resource for the active connections.
2. If it is empty, call `get_targets`, then `connect` with one of the
   socket paths. `connect_tcp` takes a TCP address instead.
3. If more than one instance is connected, ask the user which one to use.
   Do not guess.

A connection ID is a BLAKE3 hash of the target, so it stays the same
across sessions.

## Reading

`read` takes a `document` and an optional 0-based line range (`start`, and
`end` exclusive, where `-1` is the last line). A `document` is one of:

- `{"buffer_id": 12}` — a buffer that is open
- `{"project_relative_path": "src/main.rs"}`
- `{"absolute_path": "/home/fw/src/main.rs"}`

`read` also reaches a file that no buffer holds, so prefer it over a disk
read for any file in the project. `list_buffers` shows the open buffers and
their line counts. `cursor_position` gives the buffer name and the 0-based
row and column.

## Writing

This server has no buffer-write tool. To change a file:

1. Prefer `lsp_apply_edit` for a rename, a code action, or a format result.
   The change goes through Neovim, so the user sees it and keeps undo.
2. If no LSP operation fits, edit the file on disk, then reload the buffer
   with `exec_lua` and `vim.cmd('checktime')`. This prevents a
   "file changed on disk" prompt for the user.

Call `list_buffers` before a disk edit. A modified buffer holds content
that the disk does not, and a disk write discards it.

## LSP

Each `lsp_*` tool needs an `lsp_client_name`. Call `lsp_clients` for the
names. Call `wait_for_lsp_ready` after you open a file, because the client
attaches after the buffer loads.

Use LSP for a question about a symbol. It is more accurate than grep:

- `lsp_definition`, `lsp_declaration`, `lsp_type_definition`,
  `lsp_implementations`, `lsp_references`
- `lsp_document_symbols`, `lsp_workspace_symbols`, `lsp_hover`
- `lsp_call_hierarchy_prepare`, then `lsp_call_hierarchy_incoming_calls` or
  `lsp_call_hierarchy_outgoing_calls`
- `lsp_type_hierarchy_prepare`, then `lsp_type_hierarchy_supertypes` or
  `lsp_type_hierarchy_subtypes`
- `lsp_rename`, `lsp_code_actions`, `lsp_resolve_code_action`
- `lsp_formatting`, `lsp_range_formatting`, `lsp_organize_imports`

All positions are 0-based. The formatting and import tools apply their
edits by default. Pass `apply_edits: false` to get the TextEdit list back
instead.

## Diagnostics

`buffer_diagnostics` takes a buffer ID. These resources give more:

- `nvim-diagnostics://{connection_id}/workspace`
- `nvim-diagnostics://{connection_id}/buffer/{buffer_id}`

## Windows and navigation

`navigate` opens a document at a 0-based line and character.

Run window commands through `exec_lua`. Keep the terminal window in place:

- If the active window is a terminal, the file context of the user is the
  alternate window. Open a file there with
  `vim.cmd('wincmd p | edit <file> | wincmd p')`.
- If the terminal is the only window, use `vim.cmd('vsplit <file>')` so the
  terminal stays.

## exec_lua

`exec_lua` runs any Lua in the editor of the user. Use it for the window
layout, for `checktime`, and for options. Do not use it to rewrite buffer
text when `lsp_apply_edit`, or a disk edit with `checktime`, does the job.

# adoc-index (personal)

adoc-index is my personal, local MCP for semantic search over an AsciiDoc specification set. It is
a personal tool, not a team install, so it lives in my personal config. It is work in progress and
I may swap it for another local indexer later.

When adoc-index is connected and the repo has an AsciiDoc spec tree, send natural-language spec
questions to it before you read the raw `.adoc` files. The index renders the `include::` shells and
ranks with a hybrid embedding plus FTS5 keyword search. It runs fully local.

- **`gather_context(question, k_docs=4, char_budget=24000)`** — start here. It returns the most
  relevant spec sections as rendered text in one budget-capped bundle. It lists anything that did
  not fit under `omitted` with the exact follow-up call.
- **`get_doc(doc_path, heading="", max_chars=12000)`** — one document's rendered text. Pass
  `heading` (a case-insensitive substring) to fetch one section.
- **`search(query, k_docs=6)`** — ranked pointers, no bodies. Use it to survey or to widen.
- **`index_stats()`** — document and chunk counts, vector dim, and model.
- Cite each result's `source_ref` / `doc_path` and heading path.

Refresh after spec edits with `adoc-index index-docs`. It is incremental. `--rebuild` re-renders all.

# Writing rules

Apply these to every project. Do not wait for a request.

- Use the `writing:ste` skill for all prose you write: documentation, READMEs, commit
  bodies, pull-request text, code comments, and error and log strings.
