#!/usr/bin/env bash
# format.sh — format or check source files in the repo.
#
# Usage: format.sh [OPTIONS]
#
# Options:
#   -c, --check   Check formatting only; exit non-zero if violations are found (no writes)
#   -s, --staged  Operate on staged files only (git diff --cached) instead of all tracked files
#   -h, --help    Show this help message and exit
#
# Examples:
#   format.sh                    # Format all tracked files
#   format.sh --check            # Check all tracked files
#   format.sh --check --staged   # Check staged files (used by the pre-commit hook)
set -euo pipefail

# Augment PATH with common tool install locations
export PATH="$HOME/.cargo/bin:$HOME/go/bin:/usr/local/bin:$PATH"

CHECK=false
STAGED=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        -c | --check) CHECK=true ;;
        -s | --staged) STAGED=true ;;
        -h | --help)
            awk 'NR==1{next} /^[^#]/{exit} {gsub(/^# ?/,""); print}' "$0"
            exit 0
            ;;
        *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
    shift
done

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

if $STAGED; then
    mapfile -t all_staged < <(git diff --cached --name-only --diff-filter=ACMR)
    lua_files=()
    sh_files=()
    md_files=()
    for f in "${all_staged[@]}"; do
        case "$f" in
            *.lua) lua_files+=("$REPO_ROOT/$f") ;;
            *.sh)  sh_files+=("$REPO_ROOT/$f")  ;;
            *.md)  md_files+=("$REPO_ROOT/$f")  ;;
        esac
    done
else
    mapfile -t lua_files < <(git ls-files '*.lua')
    mapfile -t sh_files  < <(git ls-files '*.sh')
    mapfile -t md_files  < <(git ls-files '*.md')
fi

tag="[fmt]"
$CHECK && tag="[check]"
exit_code=0

run_lua() {
    if ! command -v stylua &>/dev/null; then
        echo "$tag stylua not found, skipping Lua. Install: cargo install stylua"
        return
    fi
    echo "$tag stylua: ${#lua_files[@]} file(s)"
    if $CHECK; then
        if ! stylua --check "${lua_files[@]}"; then
            echo "$tag stylua: formatting issues found"
            exit_code=1
        fi
    else
        stylua "${lua_files[@]}"
    fi
}

run_sh() {
    if ! command -v shfmt &>/dev/null; then
        echo "$tag shfmt not found, skipping Shell. Install: go install mvdan.cc/sh/v3/cmd/shfmt@latest"
        return
    fi
    echo "$tag shfmt: ${#sh_files[@]} file(s)"
    if $CHECK; then
        if ! shfmt -d "${sh_files[@]}"; then
            echo "$tag shfmt: formatting issues found"
            exit_code=1
        fi
    else
        shfmt -w "${sh_files[@]}"
    fi
}

run_md() {
    if ! command -v prettier &>/dev/null; then
        echo "$tag prettier not found, skipping Markdown. Install: npm install -g prettier"
        return
    fi
    echo "$tag prettier: ${#md_files[@]} file(s)"
    if $CHECK; then
        if ! prettier --check "${md_files[@]}"; then
            echo "$tag prettier: formatting issues found"
            exit_code=1
        fi
    else
        prettier --write "${md_files[@]}"
    fi
}

[[ "${#lua_files[@]}" -gt 0 ]] && run_lua
[[ "${#sh_files[@]}" -gt 0 ]]  && run_sh
[[ "${#md_files[@]}" -gt 0 ]]  && run_md

if $CHECK; then
    if [[ "$exit_code" -eq 0 ]]; then
        echo "$tag all files are correctly formatted"
    else
        echo ""
        echo "✖ Formatting violations found. Auto-fix: ./scripts/format.sh"
        echo "  Bypass hook: git commit --no-verify"
    fi
else
    echo "$tag done"
fi

exit "$exit_code"
