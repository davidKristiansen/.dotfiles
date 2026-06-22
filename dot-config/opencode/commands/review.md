---
description: Review code for issues and best practices
agent: code-reviewer
---

Review the following code for potential issues. If `$ARGUMENTS` is provided, focus the review on those files. Otherwise, review the staged changes (`git diff --cached`) or recent unstaged changes (`git diff`).

Focus on:
- **Bugs**: Logic errors, off-by-one errors, null/undefined handling, resource leaks
- **Security**: Injection vulnerabilities, hardcoded secrets, unsafe input handling, buffer overflows (C)
- **Performance**: Unnecessary allocations, O(n^2) patterns, missing caching opportunities
- **Memory safety** (C): Use-after-free, double-free, buffer overflows, missing null checks, uninitialized variables
- **Python best practices**: Type hints, proper exception handling, PEP 8 compliance
- **Readability**: Unclear naming, missing comments on complex logic, overly long functions

Provide actionable feedback with specific line references. Do NOT make changes -- only report findings.
