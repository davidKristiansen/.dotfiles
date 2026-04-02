# Agents

This repository contains personal dotfiles.

## Commit Rules

Use semantic conventional commit prefixes in the format `type(scope): <message>`. Examples:

- `chore(<scope>):` for maintenance / refactors / non-feature tweaks
- `feat(<scope>):` for new user-visible functionality
- `fix(<scope>):` for bug fixes or correcting broken behavior
- `docs(<scope>):` for documentation-only edits
- `perf(<scope>):` for performance improvements
- `style(<scope>):` for purely stylistic changes (whitespace, formatting) with no logic impact
- `refactor(<scope>):` for structural changes that neither fix a bug nor add a feature
- `test(<scope>):` for test related changes

Use a descriptive scope (e.g. `nvim`, `zsh`, `tmux`, `git`). Only one logical change per commit.

## Commit Workflow

When asked to "commit":

1. Check `git status`.
2. Stage the relevant changes.
3. Create a commit with a descriptive conventional-commit message.
4. Push if explicitly asked.

Do NOT create a new branch unless explicitly asked.

## Subsystem Instructions

- **Neovim:** See `.config/nvim/AGENTS.md` for architecture, plugin management, keymaps, and LSP configuration.

## Guidelines

- Minimize scope; touch only what the request needs.
- Ask for clarification before large structural refactors.
- Do NOT maintain a manual changelog; git history provides traceability.
