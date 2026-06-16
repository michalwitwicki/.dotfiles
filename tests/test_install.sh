#!/usr/bin/env bash
# Tests for install.sh helper functions.
# Run with: bash tests/test_install.sh
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

# ---------------------------------------------------------------------------
# Minimal test framework
# ---------------------------------------------------------------------------

PASS=0
FAIL=0

pass() {
	echo "[PASS] $1"
	PASS=$((PASS + 1))
}
fail() {
	echo "[FAIL] $1"
	FAIL=$((FAIL + 1))
}

assert_equals() {
	local desc="$1" expected="$2" actual="$3"
	if [ "$expected" = "$actual" ]; then
		pass "$desc"
	else
		fail "$desc (expected: '$expected', got: '$actual')"
	fi
}

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

assert_output_not_contains() {
	local desc="$1" pattern="$2" output="$3"
	if ! echo "$output" | grep -qF "$pattern"; then
		pass "$desc"
	else
		fail "$desc (pattern '$pattern' unexpectedly found in output)"
	fi
}

assert_count() {
	local desc="$1" expected="$2" file="$3" pattern="$4"
	local count
	count="$(grep -cF "$pattern" "$file" 2>/dev/null || true)"
	assert_equals "$desc" "$expected" "$count"
}

# ---------------------------------------------------------------------------
# Source install.sh to load all functions.
# Because BASH_SOURCE[0] != ${0} when sourced, the main() guard at the bottom
# of install.sh prevents any actions from running.
# shellcheck source=../install.sh
source "$REPO_DIR/install.sh"

# ---------------------------------------------------------------------------
# Setup / teardown
# ---------------------------------------------------------------------------

TMP_DIR=""

setup() {
	TMP_DIR="$(mktemp -d)"
	HOME="$TMP_DIR/home"
	TOOLS_DIR="$TMP_DIR/home/tools"
	BIN_DIR="$TMP_DIR/home/bin"
	mkdir -p "$HOME" "$TOOLS_DIR" "$BIN_DIR"
	DRY_RUN=0
	FLAG_ALL=0
	# Disable colours so captured output is plain text (predictable grep patterns)
	C_GREEN='' C_YELLOW='' C_RED='' C_CYAN='' C_BLUE='' C_BOLD='' C_RESET=''
}

teardown() { rm -rf "$TMP_DIR"; }

# ---------------------------------------------------------------------------
# Tests: create_symlink
# ---------------------------------------------------------------------------

test_symlink_creates_new_link() {
	local target="$TMP_DIR/target_file" link="$TMP_DIR/link"
	touch "$target"
	local out
	out="$(create_symlink "$target" "$link")"
	assert_path "symlink is created" -L "$link"
	assert_equals "symlink points to target" "$target" "$(readlink "$link")"
	assert_output_contains "reports ok" "[ ok ] Symlink created" "$out"
}

test_symlink_skips_when_already_correct() {
	local target="$TMP_DIR/target_file" link="$TMP_DIR/link"
	touch "$target"
	ln -s "$target" "$link"
	local out
	out="$(create_symlink "$target" "$link")"
	assert_output_contains "reports skip" "[skip] Symlink already exists" "$out"
}

test_symlink_replaces_wrong_symlink() {
	local target="$TMP_DIR/target_file" other="$TMP_DIR/other_file" link="$TMP_DIR/link"
	touch "$target" "$other"
	ln -s "$other" "$link"
	local out
	out="$(create_symlink "$target" "$link")"
	assert_output_contains "reports warn" "[warn] Symlink" "$out"
	assert_output_contains "reports ok after replace" "[ ok ] Symlink created" "$out"
	assert_equals "symlink points to new target" "$target" "$(readlink "$link")"
}

test_symlink_skips_regular_file() {
	local target="$TMP_DIR/target_file" link="$TMP_DIR/existing_regular_file"
	touch "$target" "$link"
	local out
	out="$(create_symlink "$target" "$link")"
	assert_output_contains "reports warn" "[warn]" "$out"
	assert_path_false "regular file not replaced" -L "$link"
}

test_symlink_creates_parent_dirs() {
	local target="$TMP_DIR/target_file" link="$TMP_DIR/nested/deep/link"
	touch "$target"
	local out
	out="$(create_symlink "$target" "$link")"
	assert_path "parent dirs created" -d "$TMP_DIR/nested/deep"
	assert_path "symlink in nested dir" -L "$link"
	assert_output_contains "reports dir creation" "[ ok ] Created directory" "$out"
}

# ---------------------------------------------------------------------------
# Tests: remove_symlink_if_ours
# ---------------------------------------------------------------------------

test_remove_symlink_removes_when_target_matches() {
	local target="$TMP_DIR/target_file" link="$TMP_DIR/link"
	touch "$target"
	ln -s "$target" "$link"
	local out
	out="$(remove_symlink_if_ours "$target" "$link")"
	assert_path_false "symlink is removed" -L "$link"
	assert_output_contains "reports ok" "[ ok ] Removed symlink" "$out"
}

test_remove_symlink_skips_when_target_differs() {
	local target="$TMP_DIR/target_file" other="$TMP_DIR/other_file" link="$TMP_DIR/link"
	touch "$target" "$other"
	ln -s "$other" "$link"
	local out
	out="$(remove_symlink_if_ours "$target" "$link")"
	assert_path "symlink is preserved" -L "$link"
	assert_output_contains "reports skip" "[skip]" "$out"
}

test_remove_symlink_skips_when_not_present() {
	local target="$TMP_DIR/target_file" link="$TMP_DIR/nonexistent_link"
	touch "$target"
	local out
	out="$(remove_symlink_if_ours "$target" "$link")"
	assert_output_contains "reports skip" "[skip]" "$out"
}

# ---------------------------------------------------------------------------
# Tests: add_to_file_if_not_present  (new BEGIN/END marker format)
# ---------------------------------------------------------------------------

test_append_to_existing_file() {
	local file="$TMP_DIR/testfile"
	touch "$file"
	local out
	out="$(add_to_file_if_not_present "$file" "myconfig" "some content here")"
	assert_output_contains "reports ok" "[ ok ] myconfig appended" "$out"
	assert_file_contains "BEGIN marker" "$file" "# === install.sh: myconfig BEGIN ==="
	assert_file_contains "END marker" "$file" "# === install.sh: myconfig END ==="
	assert_file_contains "content in file" "$file" "some content here"
}

test_append_skips_if_already_present() {
	local file="$TMP_DIR/testfile"
	# Pre-populate with the new marker format
	printf '# === install.sh: myconfig BEGIN ===\nsome content here\n# === install.sh: myconfig END ===\n' >"$file"
	local out
	out="$(add_to_file_if_not_present "$file" "myconfig" "some content here")"
	assert_output_contains "reports skip" "[skip] myconfig already present" "$out"
	assert_count "content not duplicated" "1" "$file" "some content here"
}

test_append_creates_file_if_missing() {
	local file="$TMP_DIR/nonexistent_file"
	local out
	out="$(add_to_file_if_not_present "$file" "myconfig" "new content")"
	assert_output_contains "reports warn missing file" "[warn] File" "$out"
	assert_output_contains "reports ok after creating" "[ ok ] myconfig appended" "$out"
	assert_path "file now exists" -f "$file"
	assert_file_contains "content present" "$file" "new content"
}

test_append_multiple_different_configs() {
	local file="$TMP_DIR/testfile"
	touch "$file"
	add_to_file_if_not_present "$file" "config_a" "line from a" >/dev/null
	add_to_file_if_not_present "$file" "config_b" "line from b" >/dev/null
	assert_file_contains "config_a present" "$file" "line from a"
	assert_file_contains "config_b present" "$file" "line from b"
}

test_append_with_semicolon_comment_char() {
	local file="$TMP_DIR/testgitconfig"
	touch "$file"
	local block="[include]
    path = /some/path"
	local out
	out="$(add_to_file_if_not_present "$file" "gitconfig" "$block" ";")"
	assert_output_contains "reports ok" "[ ok ] gitconfig appended" "$out"
	assert_file_contains "semicolon BEGIN" "$file" "; === install.sh: gitconfig BEGIN ==="
	assert_file_contains "semicolon END" "$file" "; === install.sh: gitconfig END ==="
	assert_file_contains "content present" "$file" "path = /some/path"
}

test_append_semicolon_skips_if_already_present() {
	local file="$TMP_DIR/testgitconfig"
	printf '; === install.sh: gitconfig BEGIN ===\n[include]\n    path = /x\n; === install.sh: gitconfig END ===\n' >"$file"
	local out
	out="$(add_to_file_if_not_present "$file" "gitconfig" "[include]" ";")"
	assert_output_contains "reports skip" "[skip] gitconfig already present" "$out"
}

# ---------------------------------------------------------------------------
# Tests: remove_from_file_section
# ---------------------------------------------------------------------------

test_remove_section_removes_marked_block() {
	local file="$TMP_DIR/testfile"
	# Add content before and after the section
	printf 'before\n' >"$file"
	add_to_file_if_not_present "$file" "mysection" "inside block" >/dev/null
	printf 'after\n' >>"$file"

	local out
	out="$(remove_from_file_section "$file" "mysection")"
	assert_output_contains "reports ok" "[ ok ] Removed mysection section" "$out"
	assert_file_contains "before preserved" "$file" "before"
	assert_file_contains "after preserved" "$file" "after"
	assert_file_not_contains "BEGIN gone" "$file" "# === install.sh: mysection BEGIN ==="
	assert_file_not_contains "END gone" "$file" "# === install.sh: mysection END ==="
	assert_file_not_contains "block content gone" "$file" "inside block"
}

test_remove_section_skips_when_not_present() {
	local file="$TMP_DIR/testfile"
	touch "$file"
	local out
	out="$(remove_from_file_section "$file" "nonexistent")"
	assert_output_contains "reports skip" "[skip]" "$out"
}

test_remove_section_skips_missing_file() {
	local file="$TMP_DIR/no_such_file"
	local out
	out="$(remove_from_file_section "$file" "mysection")"
	assert_output_contains "reports skip" "[skip]" "$out"
}

test_remove_section_with_semicolon_comment() {
	local file="$TMP_DIR/testgitconfig"
	add_to_file_if_not_present "$file" "gitconfig" "[include]
    path = /x" ";" >/dev/null
	local out
	out="$(remove_from_file_section "$file" "gitconfig" ";")"
	assert_output_contains "reports ok" "[ ok ] Removed gitconfig section" "$out"
	assert_file_not_contains "BEGIN gone" "$file" "; === install.sh: gitconfig BEGIN ==="
	assert_file_not_contains "content gone" "$file" "path = /x"
}

test_remove_section_does_not_remove_other_sections() {
	local file="$TMP_DIR/testfile"
	touch "$file"
	add_to_file_if_not_present "$file" "section_a" "content a" >/dev/null
	add_to_file_if_not_present "$file" "section_b" "content b" >/dev/null
	remove_from_file_section "$file" "section_a" >/dev/null
	assert_file_not_contains "section_a gone" "$file" "content a"
	assert_file_contains "section_b preserved" "$file" "content b"
}

# ---------------------------------------------------------------------------
# Tests: run_cmd
# ---------------------------------------------------------------------------

test_run_cmd_executes_normally() {
	DRY_RUN=0
	local target="$TMP_DIR/run_cmd_test_file"
	run_cmd touch "$target"
	assert_path "file was created" -f "$target"
}

test_run_cmd_dry_run_skips_execution() {
	DRY_RUN=1
	local target="$TMP_DIR/run_cmd_dry_file"
	local out
	out="$(run_cmd touch "$target")"
	assert_path_false "file was NOT created" -f "$target"
	assert_output_contains "prints dry message" "[dry ] Would run:" "$out"
	DRY_RUN=0
}

test_run_cmd_dry_run_includes_command_in_log() {
	DRY_RUN=1
	local out
	out="$(run_cmd echo hello world)"
	assert_output_contains "command in log" "echo hello world" "$out"
	DRY_RUN=0
}

# ---------------------------------------------------------------------------
# Tests: get_latest_github_release
# ---------------------------------------------------------------------------

# Stub curl to return a fake GitHub API response for all release tests.
_stub_curl_release() {
	curl() { echo '{"tag_name": "v0.99.0", "prerelease": false, "draft": false}'; }
}

test_get_latest_github_release_returns_tag() {
	_stub_curl_release
	local tag
	tag="$(get_latest_github_release "neovim/neovim")"
	if [ -n "$tag" ]; then
		pass "returns non-empty tag"
	else
		fail "returned empty string"
	fi
}

test_get_latest_github_release_starts_with_v() {
	_stub_curl_release
	local tag
	tag="$(get_latest_github_release "neovim/neovim")"
	if [[ "$tag" == v* ]]; then
		pass "tag starts with 'v': $tag"
	else
		fail "tag does not start with 'v': '$tag'"
	fi
}

test_get_latest_github_release_extracts_correct_value() {
	_stub_curl_release
	local tag
	tag="$(get_latest_github_release "neovim/neovim")"
	assert_equals "tag matches JSON value" "v0.99.0" "$tag"
}

# ---------------------------------------------------------------------------
# Tests: module_neovim
# ---------------------------------------------------------------------------

_stub_neovim_externals() {
	get_latest_github_release() { echo "v0.99.0"; }
	wget() {
		local outfile=""
		while [[ $# -gt 0 ]]; do
			if [[ "$1" == "-O" ]]; then
				outfile="$2"
				shift 2
			else shift; fi
		done
		[ -n "$outfile" ] && touch "$outfile"
	}
}

test_neovim_installs_appimage_and_symlink() {
	_stub_neovim_externals
	local out
	out="$(module_neovim "install")"
	local appimage="$TOOLS_DIR/neovim_0.99.0/nvim-linux-x86_64.appimage"
	assert_path "install dir created" -d "$TOOLS_DIR/neovim_0.99.0"
	assert_path "appimage file exists" -f "$appimage"
	assert_path "nvim binary symlink created" -L "$BIN_DIR/nvim"
	assert_equals "binary symlink points to appimage" "$appimage" "$(readlink "$BIN_DIR/nvim")"
	assert_path "nvim config symlink created" -L "$HOME/.config/nvim"
	assert_equals "config symlink points to nvim dir" "$SCRIPT_DIR/nvim" "$(readlink "$HOME/.config/nvim")"
	assert_output_contains "reports ok" "[ ok ]" "$out"
}

test_neovim_skips_if_symlink_exists() {
	_stub_neovim_externals
	mkdir -p "$TOOLS_DIR/neovim_0.99.0"
	local fake_appimage="$TOOLS_DIR/neovim_0.99.0/nvim-linux-x86_64.appimage"
	touch "$fake_appimage"
	ln -s "$fake_appimage" "$BIN_DIR/nvim"
	local out
	out="$(module_neovim "install")"
	assert_output_contains "reports skip" "[skip]" "$out"
}

# ---------------------------------------------------------------------------
# Run all tests
# ---------------------------------------------------------------------------

echo "=== create_symlink ==="
setup
test_symlink_creates_new_link
teardown
setup
test_symlink_skips_when_already_correct
teardown
setup
test_symlink_replaces_wrong_symlink
teardown
setup
test_symlink_skips_regular_file
teardown
setup
test_symlink_creates_parent_dirs
teardown

echo ""
echo "=== remove_symlink_if_ours ==="
setup
test_remove_symlink_removes_when_target_matches
teardown
setup
test_remove_symlink_skips_when_target_differs
teardown
setup
test_remove_symlink_skips_when_not_present
teardown

echo ""
echo "=== add_to_file_if_not_present ==="
setup
test_append_to_existing_file
teardown
setup
test_append_skips_if_already_present
teardown
setup
test_append_creates_file_if_missing
teardown
setup
test_append_multiple_different_configs
teardown
setup
test_append_with_semicolon_comment_char
teardown
setup
test_append_semicolon_skips_if_already_present
teardown

echo ""
echo "=== remove_from_file_section ==="
setup
test_remove_section_removes_marked_block
teardown
setup
test_remove_section_skips_when_not_present
teardown
setup
test_remove_section_skips_missing_file
teardown
setup
test_remove_section_with_semicolon_comment
teardown
setup
test_remove_section_does_not_remove_other_sections
teardown

echo ""
echo "=== run_cmd ==="
setup
test_run_cmd_executes_normally
teardown
setup
test_run_cmd_dry_run_skips_execution
teardown
setup
test_run_cmd_dry_run_includes_command_in_log
teardown

echo ""
echo "=== get_latest_github_release ==="
setup
test_get_latest_github_release_returns_tag
teardown
setup
test_get_latest_github_release_starts_with_v
teardown
setup
test_get_latest_github_release_extracts_correct_value
teardown

echo ""
echo "=== module_neovim ==="
setup
test_neovim_installs_appimage_and_symlink
teardown
setup
test_neovim_skips_if_symlink_exists
teardown

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
