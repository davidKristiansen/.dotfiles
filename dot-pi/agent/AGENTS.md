## Persistent Memory (mempalace)

You have access to a persistent memory system via mempalace MCP tools (bridged as pi tools). Use it to remember important context across sessions.

### When to SAVE memories

Use the mempalace write tools to store information when:
- The user makes an important decision about architecture, tooling, or workflow
- You learn something non-obvious about the codebase, environment, or user preferences
- A debugging session reveals a tricky issue and its resolution
- The user explicitly asks you to remember something
- You discover project conventions or patterns worth preserving

### How to save

- **`mempalace_add_drawer`** — store a discrete piece of knowledge (a fact, decision, convention, or solution). Use descriptive titles and tags.
- **`mempalace_diary_write`** — write a diary entry summarizing what was accomplished in a session, key decisions made, and open questions. Do this at the end of substantial sessions.
- **`mempalace_kg_add`** — add relationships to the knowledge graph (entity-relation-entity triples). Use this for structural knowledge like "project X uses framework Y" or "module A depends on module B".

### When to SEARCH memories

At the start of a session or when context would help:
- Use **`mempalace_search`** to find relevant prior knowledge before diving into a task
- Use **`mempalace_kg_query`** to explore entity relationships

### Guidelines

- Keep drawer contents concise but complete enough to be useful without surrounding context
- Use consistent tags: `decision`, `convention`, `debug`, `architecture`, `tooling`, `preference`, `til` (today I learned)
- For diary entries, use the format: what was done, what was decided, what's still open
- Don't store trivial or easily re-discoverable information (e.g., "user ran npm install")
- DO store things that took effort to figure out or that represent user intent

## Vault

The user maintains an Obsidian knowledge vault at `~/.local/share/vault` organized with Johnny Decimal conventions. Use the `vault` skill when working with vault notes.

## Context Management

Be token-conscious. Use context tools proactively — don't wait for auto-compaction or the user to ask.

### Tools

| Tool | Purpose |
|------|---------|
| `context_info` | Check token count and context budget. Use at the start of long tasks, after large outputs, or when unsure. |
| `context_log` | Visualize conversation history and token distribution. |
| `context_tag` | Create named milestones at logical breakpoints. Tag early, tag often — it's free. |
| `compact_context` | Full compaction. Use when `context_info` shows >70% usage. |
| `context_checkout` | Compress up to a tag into a summary. Prefer over full compaction when only older context is stale. |

### Reading files

- Use only the current buffer unless you need more context.
- **Search first**: `rg`/`grep`/`fd`/`find` before opening files. Read only the relevant section with offset/limit.
- **Ask before reading large files** (>500 lines). Prefer summaries over full dumps.
- **Logs and output**: use `tail`/`head`/`grep` instead of reading whole files. Use context-mode skill for large results.
- **Prefer small diffs** over showing whole files when presenting changes.

### Never read (ask before reading, skip in exploratory searches)

- VCS: `.git/`, `.hg/`, `.svn/`
- Packages: `node_modules/`, `.npm/`, `.pnpm-store/`, `.cargo/registry/`, `.gradle/`, `.m2/`
- Build output: `dist/`, `build/`, `out/`, `target/`, `_build/`
- Caches: `.cache/`, `.ccache/`, `__pycache__/`, `.mypy_cache/`, `.pytest_cache/`, `.ruff_cache/`, `.tox/`, `.nox/`
- Virtualenvs: `.venv/`, `venv/`, `.env/`
- Coverage: `coverage/`, `htmlcov/`, `.nyc_output/`
- Lock files: `*.lock`, `package-lock.json`, `bun.lock`, `yarn.lock`, `Cargo.lock`, `poetry.lock`, `uv.lock`
- Generated: `compile_commands.json`, `*.min.js`, `*.min.css`, `*.map`
- Binaries: `*.pyc`, `*.pyo`, `*.o`, `*.so`, `*.dylib`, `*.a`

### Compaction habits

- Check `context_info` during long tasks. If >70%, compact before continuing.
- Tag before switching tasks or pivoting to a different approach.
- Prefer compact summaries over repeatedly re-reading large files.
- Keep responses concise and structured.

## Environment

- Tools are managed via `mise` — never hardcode version-pinned paths
- The vault is synced via mutagen (not git)
