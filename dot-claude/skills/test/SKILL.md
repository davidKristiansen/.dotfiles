---
name: test
description: Run the project's test suite and fix any failures. Use when the user asks to run tests, check whether tests pass, or fix failing tests.
---

Run the project's test suite and get it green.

## Find the test entrypoint — check in this order

1. **Project-defined entrypoint first** — it sets env vars and flags you'd otherwise miss:
   `test` target in `Makefile` or `justfile` → `make test` / `just test`; `test` script in `package.json` → `npm test`; `tox.ini`/`noxfile.py` → `tox` / `nox`; otherwise copy the test command from the CI workflow (`.github/workflows/*.yml`).
2. **Otherwise the ecosystem default:**
   - `pytest.ini`, `conftest.py`, or `[tool.pytest]` in `pyproject.toml` → `pytest`
   - `Cargo.toml` → `cargo test`
   - `go.mod` → `go test ./...`
   - `package.json` without a test script → `npx vitest run` or `npx jest` (check devDependencies)
   - `CMakeLists.txt` → `ctest --output-on-failure` from the build directory
   - `build.gradle*` → `./gradlew test`; `pom.xml` → `mvn test`
   - Anything else: inspect the README and repo layout and use the project's documented command.
3. If the user named specific tests or files, run only those.

## Fix loop

Run → read each failure → fix the root cause in the code under test → re-run. Repeat until green.

## Guardrails

- Never make tests pass by deleting or weakening assertions, skipping/xfailing tests, or loosening tolerances. Only change a test when the test itself is provably wrong — and say so explicitly.
- If a failure reveals a real bug that's out of scope to fix now, report it clearly rather than papering over it.
- Report faithfully: if tests still fail when you stop, say so and include the failing output. Never claim green without a passing run you actually executed.
