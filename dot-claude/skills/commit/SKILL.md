---
name: commit
description: Stage, commit, and optionally push changes using Conventional Commits. Use when the user asks to commit, save changes, or push code.
disable-model-invocation: true
argument-hint: [optional scope or message hint]
allowed-tools: Bash(git status *), Bash(git diff *), Bash(git log *), Bash(git add *), Bash(git commit *), Bash(git push *), Bash(git branch *), Bash(git rev-parse *), Bash(git checkout -b *)
---

## Current state

- Branch: !`git branch --show-current`
- Status: !`git status --short`

## Checklist — copy this and check off each item

```
Commit progress:
- [ ] 1. Branch safe (not main/develop/master)
- [ ] 2. Full diff reviewed
- [ ] 3. Changes grouped into atomic commits
- [ ] 4. No secrets or identifying info staged
- [ ] 5. Committed (and pushed if appropriate)
```

**Step 1 — Branch.** Never commit directly to `main`, `develop`, or `master`. If on one, create a branch first — `git checkout -b <type>/<short-description>` where `<type>` is `feature`, `fix`, `docs`, or `refactor` — and tell the user.

**Step 2 — Review.** Read the full diff before writing any message: `git --no-pager diff` and `git --no-pager diff --cached`. If mcpipe MCP tools are available, prefer `mcpipe:git_diff` / `mcpipe:git_log` for large output (returns a handle; read with `mcpipe:view`).

**Step 3 — Group.** One commit per concern: a feature stays with its tests; unrelated changes (a parser fix + an auth refactor) become separate commits. Stage each group explicitly with `git add <paths>` — never `git add -A` without checking what it grabs.

**Step 4 — Secrets & identifying info.** Never stage `.env` files, credentials, keys, or tokens. Also keep personal/company identifiers out of diffs headed for shared or public repos: usernames and employee IDs, company email addresses, internal hostnames and URLs, and absolute `/home/<user>` paths (use `$HOME`, `%h`, or XDG variables instead). Scan the staged diff for these before committing — `git diff --cached | grep -inE '<username>|<employee-id>|corp domain'` — and if something identifying is already tracked, warn the user rather than silently committing more of it.

**Step 5 — Commit and push.** The `/commit` invocation is approval to commit. Ask before pushing to a branch that doesn't exist on the remote yet.

## Message format — Conventional Commits

```
type(scope): description

[optional body explaining the why]
```

**Types:** `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`

**Rules:** first line lowercase, imperative mood, ≤50 chars, no trailing period. Breaking changes: `!` after the type (`feat!: …`).

**Examples:**
```
feat(auth): add JWT token refresh endpoint
fix(parser): handle edge case in YAML parsing
docs: update CLI reference in README
refactor(orchestrator): simplify task execution logic
chore(deps): upgrade dependencies to latest versions
```
