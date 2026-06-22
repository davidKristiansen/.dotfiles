---
name: vault
description: Read, write, and manage notes in the Obsidian knowledge vault at ~/.local/share/vault. Uses Johnny Decimal organization with wikilink cross-references. Use when the user mentions vault, notes, or knowledge base.
---

## What this skill does

Interact with the user's personal knowledge vault — an Obsidian-compatible markdown vault stored at `~/.local/share/vault`. The vault uses the Johnny Decimal organizational system for structure and Obsidian wikilinks for cross-references.

## First steps — always do this

1. Read the vault's conventions file (look for `.github/copilot-instructions.md` or `AGENTS.md` at the vault root) for note format, cross-linking rules, tags, and the full category map. This file is the source of truth.
2. Read `~/.local/share/vault/index.md` for a quick overview of all notes and navigation links.

## Vault location

`~/.local/share/vault`

## Organization

The vault uses the Johnny Decimal system:

```
10-19  Area
  11   Category
    11.01  Individual note
```

Categories are directories (e.g., `14 Concepts/`). Notes are markdown files named `<JD#> <Title>.md`.

## Reading notes

- Use bash with `find` or `ls` to discover notes: `find ~/.local/share/vault -name '*.md'`
- Use bash with `grep -r` to search content across the vault
- Read `index.md` or `Vault Map.md` for a full directory listing
- Read `14 Concepts/14.00 Knowledge Base Hub.md` for the concept index

## Writing and updating notes

When creating or editing notes, follow these rules strictly:

1. **Read the conventions first** — always read the vault conventions file before writing
2. **Front-matter is mandatory** — every note must have YAML front-matter with `id`, `aliases`, and `tags`
3. **Cross-link aggressively** — every mention of a known concept must use a wikilink in the format `[[14 Concepts/14.XX Name|Display Name]]`
4. **Related Notes section** — every note must end with a "Related Notes" section linking to relevant pages
5. **Next available ID** — when creating a new note, list the category directory to find the next available number
6. **Update the hub** — when adding a new concept (14.XX), also update `14 Concepts/14.00 Knowledge Base Hub.md` and `index.md`

## When the user says "put this in my vault"

1. Determine the right category based on content
2. Check if an existing note covers the topic (update it rather than creating a duplicate)
3. If creating new: assign next ID, write with full front-matter and cross-links
4. If updating: preserve existing structure, add new sections or extend existing ones

## Semantic search

If a semantic-search MCP tool for the vault is available, prefer it for conceptual queries. Fall back to `grep -r` for exact string matches.

## Do not

- Do not create notes without front-matter
- Do not use plain text where a wikilink should be
- Do not guess the vault path — it is always `~/.local/share/vault`
- Do not put sensitive project paths or credentials in notes
