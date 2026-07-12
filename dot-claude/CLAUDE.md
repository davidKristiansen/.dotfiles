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

The user edits code in Neovim. You control it through nvim-mcp tools.
You already know Vim — use that knowledge.

## Rules

**⚠ CRITICAL: Call `get_state_brief` at the START of every turn — before
any nvim-mcp call, file read, or disk edit that touches a Neovim buffer.
Never carry over cursor position or file identity from a previous turn.
Use the full `get_state` only when you need deep context (folds, marks,
diagnostics, highlights, virtual text, all windows).**

1. **If a file is in `buffers`, always use buffer tools — not disk.**
   Read with `read_full_buf` (or `read_buf_range` for a slice).
   Edit with `find_and_replace_buf` (or `write_full_buf` for full content).
   This ensures the user sees changes immediately and gets undo.
   Fall back to disk only if the file isn't in `buffers`.
2. **The user's context is the active window.** If the active window
   is a terminal, the user's file context is the alternate window.
   When opening files in that case, use
   `send_command(["wincmd p", "e <file>", "wincmd p"])`.
   If the terminal is the only window, use
   `send_command("vsplit <file>")` to avoid replacing it.
3. **Keep the terminal window in place when splitting.** If a terminal
   window exists, open new splits from a non-terminal window so the
   terminal stays where it is. Switch to a file window first
   (`wincmd p` or target it directly), run the split there, then
   switch back if needed.

## Colors

Both `highlight_range` and `add_virtual_text` accept the same two
color formats:

- Hex code (e.g. `#3b4048`) — used as-is.
- Highlight group name (e.g. `Comment`, `DiagnosticError`) — adapts
  to the user's colorscheme. For `highlight_range`, the group's
  foreground color is used as the line background. For
  `add_virtual_text`, the group is used directly.

Unknown names (including bare color literals like `Red` or
`darkgreen`) return an error. Use either a hex code or a valid
highlight group.

### Recommended highlight groups

When using `highlight_range` or `add_virtual_text`, prefer these
groups so the visual semantics stay consistent and adapt to the
colorscheme:

- Notes / context (default for both tools): `Comment`
- Errors / problems: `DiagnosticError`
- Warnings / caution: `DiagnosticWarn`
- Info / context: `DiagnosticInfo`
- Hints / suggestions: `DiagnosticHint`
- Good / success: `DiagnosticOk`

Pass the group name as the `color` argument
(e.g. `color="DiagnosticError"`). Both tools default to `Comment`
when no color is provided.

## Virtual text

**⚠ MANDATORY: every `add_virtual_text` / `add_virtual_texts` text item
MUST start with `※ ` (U+203B, "Reference Mark"). No exceptions, every
call, every item. Example: `text=["※ swap if reversed"]`.**

- Keep each annotation **single-line and short**. No `\n`. One item per
  `text` list. If you need more, place several short annotations on
  adjacent lines instead.
- `color`: default `Comment`. Use a `Diagnostic*` group only when
  semantics demand it.
- `position`: default `"eol"`. Use `"above"` / `"below"` only when the
  annotated line is already long.

## Multi-instance

Multiple Neovim instances: `connect` lists them. Ask the user which
one — don't guess
