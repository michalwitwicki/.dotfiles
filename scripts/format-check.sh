#!/usr/bin/env bash
# format-check.sh — check formatting without modifying files.
# Exits non-zero if any file needs formatting.
# Suitable for dry-runs and future CI integration.
set -euo pipefail

# Augment PATH with common tool install locations
export PATH="$HOME/.cargo/bin:$HOME/go/bin:/usr/local/bin:$PATH"

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

mapfile -t lua_files < <(git ls-files '*.lua')
mapfile -t sh_files  < <(git ls-files '*.sh')
mapfile -t md_files  < <(git ls-files '*.md')

exit_code=0

if [[ "${#lua_files[@]}" -gt 0 ]]; then
    echo "[check] stylua: ${#lua_files[@]} file(s)"
    if ! stylua --check "${lua_files[@]}"; then
        echo "[FAIL] stylua: formatting issues found"
        exit_code=1
    fi
fi

if [[ "${#sh_files[@]}" -gt 0 ]]; then
    echo "[check] shfmt: ${#sh_files[@]} file(s)"
    if ! shfmt -d "${sh_files[@]}" | grep -q .; then
        : # no diff output means clean
    else
        shfmt -d "${sh_files[@]}"
        echo "[FAIL] shfmt: formatting issues found"
        exit_code=1
    fi
fi

if [[ "${#md_files[@]}" -gt 0 ]]; then
    echo "[check] prettier: ${#md_files[@]} file(s)"
    if ! prettier --check "${md_files[@]}"; then
        echo "[FAIL] prettier: formatting issues found"
        exit_code=1
    fi
fi

if [[ "$exit_code" -eq 0 ]]; then
    echo "[check] all files are correctly formatted"
fi

exit "$exit_code"
