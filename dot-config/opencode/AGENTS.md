# Global Rules

## Knowledge Vault

Before starting a task, load the `vault` skill and search for relevant existing notes.

When the conversation produces noteworthy knowledge, ask if it should go in the vault.

## draw.io Diagrams

When creating draw.io diagrams, always ensure they are readable in both light and dark mode:

- Set `adaptiveColors="auto"` on the `<mxGraphModel>` root element
- Fill colors are auto-inverted — no action needed
- Use `light-dark(lightColor,darkColor)` for all `fontColor`, `strokeColor`, and edge colors that would otherwise be a single dark or light value
- Common pairs: `light-dark(#003366,#a1cdf9)` for text/edges, `light-dark(#333,#ccc)` for note text, `light-dark(#827717,#c4b84e)` for note accents
- For inline HTML color attributes in labels, use `style="color:light-dark(#666,#aaa)"` instead of `color="#666"`
- Never hardcode a single dark color for text/strokes without a `light-dark()` wrapper

## mcpipe Tools

The `mcpipe` MCP server provides cached, paginated tools for git, docker, docker compose, and filesystem operations. **Prefer mcpipe tools over raw bash commands** for these domains — they cache output and let you explore it incrementally instead of dumping everything into context.

### How it works

1. Call a tool (e.g. `mcpipe_git_log`). You get back a **handle** + summary.
2. Use `mcpipe_view` with that handle to explore: `_search` to filter, `_offset`/`_limit` to paginate, `_head`/`_tail` for ends.
3. Output is never lost — re-view the same handle anytime.

### When to use which

| Task | Use mcpipe | Not bash |
|------|-----------|----------|
| Git operations (status, log, diff, branch, add, commit) | `mcpipe_git_*` | `git ...` |
| Docker containers (ps, logs, images) | `mcpipe_docker_*` | `docker ...` |
| Docker Compose (ps, logs, up, down, exec, run, config, etc.) | `mcpipe_compose_*` | `docker compose ...` |
| Filesystem read (read files, list dirs, stat, find, grep) | `mcpipe_fs_*` | `cat`, `ls`, `find`, `grep` |
| Filesystem write (write, mkdir, rm, mv, cp) | `mcpipe_fs_*` | `echo >`, `mkdir`, `rm`, `mv`, `cp` |

### Filesystem tools — access control

`mcpipe_fs_*` tools enforce root restrictions. By default only CWD is allowed. Use `mcpipe_fs_roots` to see allowed paths. If access is denied, the tool returns an error — don't fall back to bash to bypass it.

### Tips

- For large outputs (long logs, big diffs), always use `_search` or `_limit` on `mcpipe_view` instead of reading everything at once.
- `mcpipe_handles` lists all active cached outputs if you need to revisit something.
- `mcpipe_compose_exec` and `mcpipe_compose_run` are for running commands inside containers — use these instead of `docker compose exec` via bash.
