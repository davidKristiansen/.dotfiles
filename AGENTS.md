# Agents

This repository contains personal dotfiles.

## Subsystem Instructions

- **Neovim:** See `.config/nvim/AGENTS.md` for architecture, plugin management, keymaps, and LSP configuration.

## Tooling

- The git pager is [`hunk`](https://github.com/modem-dev/hunk) (`core.pager = hunk pager`), an
  interactive TUI for humans. When reading diffs programmatically, use `git --no-pager diff`
  (or pipe to `cat`) so output is captured as plain text instead of launching the viewer.

## Guidelines

- Minimize scope; touch only what the request needs.
- Ask for clarification before large structural refactors.
- Do NOT maintain a manual changelog; git history provides traceability.
- Do NOT create a new branch unless explicitly asked.
