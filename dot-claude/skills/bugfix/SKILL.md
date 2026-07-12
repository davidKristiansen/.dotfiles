---
name: bugfix
description: Fix a bug by first reproducing it as a failing test, then making the minimal change that turns it green. Use whenever the user reports a bug, a regression, unexpected behavior, a crash, or a wrong result and wants it fixed — even if they just say "fix this" or paste a stack trace without mentioning tests.
argument-hint: [bug description, stack trace, or issue reference]
---

Reproduce first, fix second. A failing test written before the fix proves you actually
understand the bug, guarantees the fix is verified rather than assumed, and stays behind
as a permanent regression guard. It also naturally keeps the diff small: the goal becomes
"make this one test pass", not "improve the area around the bug".

## 1. Understand and locate

Read the report, stack trace, or repro steps. Trace to the root cause in the code —
not just the line that crashed. If the reported symptom and the actual defect are in
different places, say so before fixing.

## 2. Reproduce as a failing test (red)

Find the test entrypoint the same way the `test` skill does (Makefile/justfile target,
`package.json` script, CI workflow, or the ecosystem default).

- Write the test where similar tests already live, in the project's existing style and
  framework. Name it after the behavior, not the ticket: `test_parse_handles_empty_header`,
  not `test_bug_1234`.
- Assert the **correct** behavior, so the test fails now and passes after the fix.
- **Run it and watch it fail — for the right reason.** A test failing on an import error
  or fixture typo proves nothing. The failure output must show the bug's actual symptom.
  If the test passes before any fix, you haven't reproduced the bug; stop and dig deeper
  rather than fixing blind.

If there is no test suite, don't bootstrap a framework as a side effect. Write a minimal
standalone repro script (scratchpad is fine), verify it shows the bug, and use it the same
way: red before, green after. Mention that the project would benefit from tests.

If the bug genuinely can't be captured in a test (race, environment-specific, interactive
UI), document the exact manual repro steps you used and verify them before and after.

## 3. Minimal fix (green)

Make the smallest change that fixes the root cause and turns the test green.

- No drive-by refactors, renames, or cleanups in the same change — a reviewer should see
  only the bug and its fix in the diff. Note adjacent problems you spot instead of
  fixing them.
- Never make the test pass by weakening its assertion or special-casing the test's input.
- If the minimal fix would paper over a deeper design problem, fix the bug minimally
  anyway and report the deeper issue separately.

## 4. Verify

1. The new test passes.
2. The rest of the suite still passes (or is failing only in ways that predate your
   change — verify with git stash or the base branch, and say so).
3. Report faithfully: show the red run and the green run. If you couldn't reproduce or
   the suite isn't green, say exactly that — never claim fixed without a verified pass.

The regression test ships with the fix in the same commit.
