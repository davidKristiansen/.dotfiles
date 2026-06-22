---
description: Stage, commit, and push with conventional commits and best practices
---

Follow this commit workflow:

### 1. Check the Current Branch
Run `git rev-parse --abbrev-ref HEAD` to verify the current branch.

If on a protected branch (`main`, `develop`, or `master`):
- **DO NOT** proceed with the commit
- Suggest creating a branch with a naming pattern like:
  - `feature/short-description` for new features
  - `fix/short-description` for bug fixes
  - `docs/short-description` for documentation
  - `refactor/short-description` for refactoring
- Create and switch to the new branch with `git checkout -b <branch-name>`

### 2. Review Changes
Run `git status`, `git diff`, and `git diff --cached` to understand all changes.

### 3. Suggest Logical Chunking
If staged changes touch multiple unrelated areas (different directories/concerns, independent features or fixes, different subsystems):
- Suggest splitting into logical commits
- Keep related changes together (a feature and its tests, a fix and related docs)
- Separate independent changes (a parser fix + auth refactoring = 2 commits)

### 4. Stage Changes
Stage the appropriate files with `git add`. NEVER commit `.env` files, credentials, or secrets.

### 5. Draft the Commit Message
Use [Conventional Commits](https://www.conventionalcommits.org/) format:

```
type(scope): description

[optional body explaining the why]
```

**Valid types:** `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`

**Rules:**
- Description must be lowercase and concise (50 chars max for first line)
- Use imperative mood ("add feature" not "added feature")
- No period at the end
- Breaking changes: add `!` after the type: `feat!: breaking change`

**Examples:**
```
feat(auth): add JWT token refresh endpoint
fix(parser): handle edge case in YAML parsing
docs: update CLI reference in README
refactor(orchestrator): simplify task execution logic
chore(deps): upgrade dependencies to latest versions
```

### 6. Co-authored Tag
Ask the user if they want to add a co-authored-by tag:
```
Co-authored-by: github-copilot[bot] <175728472+github-copilot[bot]@users.noreply.github.com>
```

### 7. Execute and Push
Commit with the approved message, then push to the remote.

If `$ARGUMENTS` is provided, use it as additional context for the commit message.

### Notes
- Always ask before creating branches or making commits
- Atomic commits are easier to review and revert
