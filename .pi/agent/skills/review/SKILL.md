---
name: review
description: Review code for bugs, security issues, and best practices. Use when the user asks to review code, check for issues, or audit changes.
---

Review code for potential issues. If specific files are mentioned, focus on those. Otherwise, review staged changes (`git diff --cached`) or recent unstaged changes (`git diff`).

## Automated Checks First

Before doing manual review, run available automated tooling:

### Python Projects
- Look for a `pyproject.toml` in the project root
- If **poethepoet** (poe) tasks are configured, run: `poe lint`, `poe typecheck`, `poe test`
- If poe is not available, fall back to whatever is configured (ruff, mypy, pytest, etc.)
- Report the tool output and focus manual review on issues tools can't catch

### Shell Scripts
- Run `shellcheck` if available
- Check for unquoted variables, missing error handling, non-portable syntax

### C/C++
- Run available linters or static analyzers (cppcheck, clang-tidy) if configured
- Focus on memory safety, undefined behavior, and resource leaks

### General
- If a Makefile, justfile, or task runner exists, check for lint/test/check targets and run them

## Manual Review Focus

### Logic & Correctness
- Off-by-one errors, incorrect boundary conditions
- Race conditions and concurrency problems
- Resource leaks (file handles, connections, subprocesses)
- Error handling gaps — swallowed errors, missing edge cases

### Security
- Injection vulnerabilities (SQL, command, path traversal)
- Hardcoded credentials or secrets
- Unsafe deserialization
- Missing input validation

### Design & Maintainability
- Unclear naming or confusing control flow
- Unnecessary complexity that could be simplified
- Missing or misleading comments
- API misuse or incorrect assumptions about libraries

### Performance
- Unnecessary O(n²) or worse algorithms
- Repeated expensive computations that could be cached
- Obvious memory or I/O waste

## Rules
- Always reference specific files and line numbers
- Rate severity: **critical**, **warning**, or **suggestion**
- Be direct and concise. No fluff.
