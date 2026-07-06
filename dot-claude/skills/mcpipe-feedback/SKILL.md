---
name: mcpipe-feedback
description: Record a bug, papercut, or improvement idea about mcpipe in the feedback log at ~/src/mcpipe/mcpipe-feedback.md. Use whenever an mcpipe tool misbehaves, surprises, or could work better — even when noticed incidentally during unrelated work.
argument-hint: [observation]
---

David Kristiansen is the author of mcpipe; feedback noticed in the field goes straight into the repo's log. Do not silently ignore an observation.

Append to `~/src/mcpipe/mcpipe-feedback.md`:

1. Check for an existing entry on the same issue first: `grep -in "<tool or keyword>" ~/src/mcpipe/mcpipe-feedback.md` — extend it rather than duplicating.
2. Otherwise append a new entry:

```
## <short title>

**Type:** bug | suggestion | question
**Context:** <what you were doing when you noticed it>
**Detail:** <clear description>
```

Keep it factual and reproducible: exact tool name, arguments used, observed vs expected behavior. One entry per distinct issue.
