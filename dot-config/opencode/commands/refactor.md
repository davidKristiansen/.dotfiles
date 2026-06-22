---
description: Refactor code with best practices
---

Refactor the code specified by `$ARGUMENTS`. If no arguments given, ask which files or functions to refactor.

Follow these principles:
- **Single responsibility**: Each function/module should do one thing well
- **DRY**: Extract repeated patterns into shared functions
- **Clear naming**: Variables and functions should describe their purpose
- **Reduce complexity**: Simplify nested conditionals, break up long functions
- **Improve error handling**: Add proper error paths, don't silently swallow errors

For C code:
- Ensure proper memory management (no leaks, clear ownership)
- Use `const` where appropriate
- Prefer stack allocation over heap when possible
- Add bounds checking

For Python code:
- Add type hints where missing
- Use context managers for resource management
- Prefer list comprehensions over manual loops where readable
- Use dataclasses/NamedTuples over raw dicts for structured data
- Follow PEP 8 conventions

After refactoring:
1. Explain what was changed and why
2. Run any existing tests to verify nothing broke
3. If no tests exist, suggest which tests should be written
