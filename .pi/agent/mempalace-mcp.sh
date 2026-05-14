#!/usr/bin/env bash
# Wrapper to run mempalace MCP server using the pipx venv's Python
# This avoids hardcoding the mise install version path
export ORT_LOG_LEVEL=3  # Suppress ONNX Runtime GPU warnings
MEMPALACE_BIN="$(mise which mempalace 2>/dev/null || which mempalace)"
VENV_DIR="$(dirname "$(dirname "$MEMPALACE_BIN")")"
exec "$VENV_DIR/mempalace/bin/python" -m mempalace.mcp_server "$@"
