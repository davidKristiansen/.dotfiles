---
name: test
description: Run tests and fix any failures. Use when the user asks to run tests, check if tests pass, or fix failing tests.
---

Run the project's test suite. Detect the test framework automatically:

- If `pytest.ini`, `pyproject.toml` with `[tool.pytest]`, or `conftest.py` exists, run `pytest -v`
- If a `Makefile` with a `test` target exists, run `make test`
- If `CMakeLists.txt` exists with `ctest`, run `ctest --output-on-failure`
- If `package.json` with a `test` script exists, run `npm test`

If specific test targets are mentioned, use those (e.g., a specific file or test name).

After running:
1. If all tests pass, report the summary
2. If any tests fail, analyze each failure, identify the root cause, and fix the code
3. Re-run the failing tests to confirm the fix
4. Repeat until all tests pass
