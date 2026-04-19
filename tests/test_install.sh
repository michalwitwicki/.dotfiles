#!/usr/bin/env bash
# Tests for install.sh helper functions and install actions.
# Run with: bash tests/test_install.sh
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

# ---------------------------------------------------------------------------
# Minimal test framework
# ---------------------------------------------------------------------------

PASS=0
FAIL=0

pass() { echo "[PASS] $1"; PASS=$((PASS + 1)); }
fail() { echo "[FAIL] $1"; FAIL=$((FAIL + 1)); }

assert_equals() {
    local desc="$1" expected="$2" actual="$3"
    if [ "$expected" = "$actual" ]; then
        pass "$desc"
    else
        fail "$desc (expected: '$expected', got: '$actual')"
    fi
}

# Assert that a file/path test expression is true.
# Usage: assert_path "<desc>" -L "/some/path"
assert_path() {
    local desc="$1" flag="$2" path="$3"
    if [ "$flag" "$path" ]; then
        pass "$desc"
    else
        fail "$desc (test $flag '$path' failed)"
    fi
}

assert_path_false() {
    local desc="$1" flag="$2" path="$3"
    if [ ! "$flag" "$path" ]; then
        pass "$desc"
    else
        fail "$desc (expected test $flag '$path' to be false)"
    fi
}

assert_file_contains() {
    local desc="$1" file="$2" pattern="$3"
    if grep -qF "$pattern" "$file" 2>/dev/null; then
        pass "$desc"
    else
        fail "$desc (pattern '$pattern' not found in '$file')"
    fi
}

assert_file_not_contains() {
    local desc="$1" file="$2" pattern="$3"
    if ! grep -qF "$pattern" "$file" 2>/dev/null; then
        pass "$desc"
    else
        fail "$desc (pattern '$pattern' unexpectedly found in '$file')"
    fi
}

assert_output_contains() {
    local desc="$1" pattern="$2" output="$3"
    if echo "$output" | grep -qF "$pattern"; then
        pass "$desc"
    else
        fail "$desc (pattern '$pattern' not found in output)"
    fi
}

assert_count() {
    local desc="$1" expected="$2" file="$3" pattern="$4"
    local count
    count="$(grep -cF "$pattern" "$file" 2>/dev/null || true)"
    assert_equals "$desc" "$expected" "$count"
}

# ---------------------------------------------------------------------------
# Source only the helper functions from install.sh (skip action lines)
# ---------------------------------------------------------------------------

_functions_only="$(awk '/^# --- Create symbolic links ---/{exit} {print}' "$REPO_DIR/install.sh")"
eval "$_functions_only"

# ---------------------------------------------------------------------------
# Setup / teardown
# ---------------------------------------------------------------------------

TMP_DIR=""

setup() { TMP_DIR="$(mktemp -d)"; }
teardown() { rm -rf "$TMP_DIR"; }

# ---------------------------------------------------------------------------
# Tests: create_symlink
# ---------------------------------------------------------------------------

test_symlink_creates_new_link() {
    local target="$TMP_DIR/target_file"
    local link="$TMP_DIR/link"
    touch "$target"
    local out
    out="$(create_symlink "$target" "$link")"
    assert_path       "symlink is created"           -L "$link"
    assert_equals     "symlink points to target"     "$target" "$(readlink "$link")"
    assert_output_contains "reports ok" "[ ok ] Symlink created" "$out"
}

test_symlink_skips_when_already_correct() {
    local target="$TMP_DIR/target_file"
    local link="$TMP_DIR/link"
    touch "$target"
    ln -s "$target" "$link"
    local out
    out="$(create_symlink "$target" "$link")"
    assert_output_contains "reports skip"            "[skip] Symlink already exists" "$out"
    assert_equals "symlink still points to target"   "$target" "$(readlink "$link")"
}

test_symlink_replaces_wrong_symlink() {
    local target="$TMP_DIR/target_file"
    local other="$TMP_DIR/other_file"
    local link="$TMP_DIR/link"
    touch "$target" "$other"
    ln -s "$other" "$link"
    local out
    out="$(create_symlink "$target" "$link")"
    assert_output_contains "reports warn"            "[warn] Symlink" "$out"
    assert_output_contains "reports ok after replace" "[ ok ] Symlink created" "$out"
    assert_equals "symlink now points to new target" "$target" "$(readlink "$link")"
}

test_symlink_skips_regular_file() {
    local target="$TMP_DIR/target_file"
    local link="$TMP_DIR/existing_regular_file"
    touch "$target" "$link"
    local out
    out="$(create_symlink "$target" "$link")"
    assert_output_contains "reports warn for regular file" "[warn]" "$out"
    assert_path_false "regular file not replaced" -L "$link"
}

test_symlink_creates_parent_dirs() {
    local target="$TMP_DIR/target_file"
    local link="$TMP_DIR/nested/deep/link"
    touch "$target"
    local out
    out="$(create_symlink "$target" "$link")"
    assert_path   "parent directories created"       -d "$TMP_DIR/nested/deep"
    assert_path   "symlink created in nested dir"    -L "$link"
    assert_output_contains "reports dir creation"    "[ ok ] Created directory" "$out"
}

# ---------------------------------------------------------------------------
# Tests: add_to_file_if_not_present
# ---------------------------------------------------------------------------

test_append_to_existing_file() {
    local file="$TMP_DIR/testfile"
    touch "$file"
    local block="# Added by .dotfiles/install.sh - myconfig
some content here"
    local out
    out="$(add_to_file_if_not_present "$file" "myconfig" "$block")"
    assert_output_contains "reports ok"              "[ ok ] myconfig appended" "$out"
    assert_file_contains   "marker in file"          "$file" "Added by .dotfiles/install.sh - myconfig"
    assert_file_contains   "content in file"         "$file" "some content here"
}

test_append_skips_if_already_present() {
    local file="$TMP_DIR/testfile"
    local block="# Added by .dotfiles/install.sh - myconfig
some content here"
    printf '\n%s\n' "$block" > "$file"
    local out
    out="$(add_to_file_if_not_present "$file" "myconfig" "$block")"
    assert_output_contains "reports skip"            "[skip] myconfig already present" "$out"
    assert_count           "content not duplicated"  "1" "$file" "some content here"
}

test_append_creates_file_if_missing() {
    local file="$TMP_DIR/nonexistent_file"
    local block="# Added by .dotfiles/install.sh - myconfig
new content"
    local out
    out="$(add_to_file_if_not_present "$file" "myconfig" "$block")"
    assert_output_contains "reports warn missing file" "[warn] File" "$out"
    assert_output_contains "reports ok after creating" "[ ok ] myconfig appended" "$out"
    assert_path            "file now exists"           -f "$file"
    assert_file_contains   "content present"           "$file" "new content"
}

test_append_multiple_different_configs() {
    local file="$TMP_DIR/testfile"
    touch "$file"
    add_to_file_if_not_present "$file" "config_a" \
        "# Added by .dotfiles/install.sh - config_a
line from a" > /dev/null
    add_to_file_if_not_present "$file" "config_b" \
        "# Added by .dotfiles/install.sh - config_b
line from b" > /dev/null
    assert_file_contains "config_a marker present"   "$file" "config_a"
    assert_file_contains "config_b marker present"   "$file" "config_b"
    assert_file_contains "config_a content present"  "$file" "line from a"
    assert_file_contains "config_b content present"  "$file" "line from b"
}

# ---------------------------------------------------------------------------
# Integration tests: install.sh run against a fake HOME
# ---------------------------------------------------------------------------

test_install_creates_all_symlinks() {
    local fake_home="$TMP_DIR/home"
    mkdir -p "$fake_home"
    HOME="$fake_home" bash "$REPO_DIR/install.sh" > /dev/null 2>&1
    assert_path ".tmux.conf symlink created"  -L "$fake_home/.tmux.conf"
    assert_path ".inputrc symlink created"    -L "$fake_home/.inputrc"
    assert_path ".gdbinit symlink created"    -L "$fake_home/.gdbinit"
    assert_path "nvim symlink created"        -L "$fake_home/.config/nvim"
}

test_install_symlinks_point_to_repo() {
    local fake_home="$TMP_DIR/home"
    mkdir -p "$fake_home"
    HOME="$fake_home" bash "$REPO_DIR/install.sh" > /dev/null 2>&1
    assert_equals ".tmux.conf target" "$REPO_DIR/configs/.tmux.conf" "$(readlink "$fake_home/.tmux.conf")"
    assert_equals ".inputrc target"   "$REPO_DIR/configs/.inputrc"   "$(readlink "$fake_home/.inputrc")"
    assert_equals ".gdbinit target"   "$REPO_DIR/configs/.gdbinit"   "$(readlink "$fake_home/.gdbinit")"
    assert_equals "nvim target"       "$REPO_DIR/nvim"               "$(readlink "$fake_home/.config/nvim")"
}

test_install_appends_to_bashrc() {
    local fake_home="$TMP_DIR/home"
    mkdir -p "$fake_home"
    touch "$fake_home/.bashrc"
    HOME="$fake_home" bash "$REPO_DIR/install.sh" > /dev/null 2>&1
    assert_file_contains "bashrc marker present" "$fake_home/.bashrc" \
        "Added by .dotfiles/install.sh - source custom bashrc"
    assert_file_contains "bashrc sources custom bashrc" "$fake_home/.bashrc" ".bashrc"
}

test_install_appends_to_gitconfig() {
    local fake_home="$TMP_DIR/home"
    mkdir -p "$fake_home"
    HOME="$fake_home" bash "$REPO_DIR/install.sh" > /dev/null 2>&1
    assert_file_contains "gitconfig marker present" "$fake_home/.gitconfig" \
        "Added by .dotfiles/install.sh - include custom gitconfig"
    assert_file_contains "gitconfig has include section" "$fake_home/.gitconfig" "[include]"
}

test_install_is_idempotent() {
    local fake_home="$TMP_DIR/home"
    mkdir -p "$fake_home"
    HOME="$fake_home" bash "$REPO_DIR/install.sh" > /dev/null 2>&1
    HOME="$fake_home" bash "$REPO_DIR/install.sh" > /dev/null 2>&1
    assert_count "bashrc marker not duplicated"    "1" "$fake_home/.bashrc"    "source custom bashrc"
    assert_count "gitconfig marker not duplicated" "1" "$fake_home/.gitconfig" "include custom gitconfig"
    assert_path  ".tmux.conf symlink intact"  -L "$fake_home/.tmux.conf"
    assert_path  "nvim symlink intact"        -L "$fake_home/.config/nvim"
}

test_install_preserves_existing_bashrc_content() {
    local fake_home="$TMP_DIR/home"
    mkdir -p "$fake_home"
    echo "existing bashrc line" > "$fake_home/.bashrc"
    HOME="$fake_home" bash "$REPO_DIR/install.sh" > /dev/null 2>&1
    assert_file_contains "original bashrc content preserved" "$fake_home/.bashrc" "existing bashrc line"
}

# ---------------------------------------------------------------------------
# Run all tests
# ---------------------------------------------------------------------------

echo "=== create_symlink ==="
setup; test_symlink_creates_new_link;         teardown
setup; test_symlink_skips_when_already_correct; teardown
setup; test_symlink_replaces_wrong_symlink;   teardown
setup; test_symlink_skips_regular_file;       teardown
setup; test_symlink_creates_parent_dirs;      teardown

echo ""
echo "=== add_to_file_if_not_present ==="
setup; test_append_to_existing_file;          teardown
setup; test_append_skips_if_already_present;  teardown
setup; test_append_creates_file_if_missing;   teardown
setup; test_append_multiple_different_configs; teardown

echo ""
echo "=== install.sh integration ==="
setup; test_install_creates_all_symlinks;          teardown
setup; test_install_symlinks_point_to_repo;        teardown
setup; test_install_appends_to_bashrc;             teardown
setup; test_install_appends_to_gitconfig;          teardown
setup; test_install_is_idempotent;                 teardown
setup; test_install_preserves_existing_bashrc_content; teardown

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
