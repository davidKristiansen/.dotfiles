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

Custom plugins live in `~/.config/mcpipe/plugins/` or `./mcpipe_plugins/`.

### Feedback

David Kristiansen is the **author** of mcpipe. Whenever you notice a bug, papercut, or
improvement idea — even incidental to the current task — append it to `FEEDBACK.md` in
the mcpipe repo (`~/src/mcpipe/FEEDBACK.md`). Do not silently ignore it.

Format:
```
## <short title>

**Type:** bug | suggestion | question
**Context:** <what you were doing when you noticed it>
**Detail:** <clear description>
```
