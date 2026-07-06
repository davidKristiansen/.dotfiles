---
name: vault
description: Read, write, and manage notes in the Obsidian knowledge vault at ~/.local/share/vault. Johnny Decimal organization with wikilink cross-references.
when_to_use: When the user mentions their vault, notes, or knowledge base, or says things like "put this in my vault" or "add a note about this".
---

Interact with the user's personal knowledge vault — an Obsidian-compatible markdown vault at `~/.local/share/vault`, organized with the Johnny Decimal system and Obsidian wikilinks.

## Standing instruction

Before writing anything, read the vault's conventions file (`.github/copilot-instructions.md` or `AGENTS.md` at the vault root). It is the source of truth for note format, cross-linking rules, tags, and the full category map. `index.md` gives a quick overview of all notes.

## Organization

```
10-19  Area
  11   Category            → directory, e.g. `14 Concepts/`
    11.01  Individual note → file named `<JD#> <Title>.md`
```

## Reading

- Discover: `find ~/.local/share/vault -name '*.md'`; search: `grep -r`
- `index.md` / `Vault Map.md` — full listing; `14 Concepts/14.00 Knowledge Base Hub.md` — concept index
- Prefer a vault semantic-search MCP tool for conceptual queries if one is available; `grep` for exact strings

## Writing and updating

1. **Front-matter is mandatory** — every note needs YAML front-matter with `id`, `aliases`, and `tags`
2. **Cross-link aggressively** — every mention of a known concept uses a wikilink: `[[14 Concepts/14.XX Name|Display Name]]`
3. **Related Notes section** — every note ends with one, linking to relevant pages
4. **Next available ID** — list the category directory to find the next free number
5. **Update the hub** — a new concept (14.XX) also gets added to `14.00 Knowledge Base Hub.md` and `index.md`

## When the user says "put this in my vault"

1. Read the conventions file (standing instruction above), then `index.md`.
2. Search for an existing note on the topic: `grep -ril "<topic>" ~/.local/share/vault --include='*.md'`. If found, **update it** — preserve its structure and front-matter — instead of creating a duplicate. Stop here.
3. Pick the category from the map in the conventions file, then find the next free ID: `ls ~/.local/share/vault/"<NN Category>"/`.
4. Create `<JD#> <Title>.md` following rules 1–3 above.
5. Apply rule 5: register new concepts in the hub and `index.md`.

## Do not

- Create notes without front-matter, or use plain text where a wikilink belongs
- Guess the vault path — it is always `~/.local/share/vault`
- Put sensitive project paths or credentials in notes
