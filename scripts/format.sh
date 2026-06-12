#!/usr/bin/env bash
# format.sh — format ALL tracked files in the repo.
# Useful for a one-shot cleanup or after changing formatter config.
set -euo pipefail

# Augment PATH with common tool install locations
export PATH="$HOME/.cargo/bin:$HOME/go/bin:/usr/local/bin:$PATH"

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

mapfile -t lua_files < <(git ls-files '*.lua')
mapfile -t sh_files  < <(git ls-files '*.sh')
mapfile -t md_files  < <(git ls-files '*.md')

if [[ "${#lua_files[@]}" -gt 0 ]]; then
    echo "[fmt] stylua: ${#lua_files[@]} file(s)"
    stylua "${lua_files[@]}"
fi

if [[ "${#sh_files[@]}" -gt 0 ]]; then
    echo "[fmt] shfmt: ${#sh_files[@]} file(s)"
    shfmt -w "${sh_files[@]}"
fi

if [[ "${#md_files[@]}" -gt 0 ]]; then
    echo "[fmt] prettier: ${#md_files[@]} file(s)"
    prettier --write "${md_files[@]}"
fi

echo "[fmt] done"
