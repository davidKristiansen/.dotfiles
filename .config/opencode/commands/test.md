---
description: Run tests and fix any failures
---

Run the project's test suite. Detect the test framework automatically:

- If `pytest.ini`, `pyproject.toml` with `[tool.pytest]`, or `conftest.py` exists, run `uv pytest -v`
- If a `Makefile` with a `test` target exists, run `make test`
- If `CMakeLists.txt` exists with `ctest`, run `ctest --output-on-failure`

If `$ARGUMENTS` is provided, use it as the test target (e.g., a specific file or test name).

After running:
1. If all tests pass, report the summary
2. If any tests fail, analyze each failure, identify the root cause, and fix the code
3. Re-run the failing tests to confirm the fix
4. Repeat until all tests pass
