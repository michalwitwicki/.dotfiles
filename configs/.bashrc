#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# --- Settings ---
# user specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=20000

# append to the history file, don't overwrite it
shopt -s histappend

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# expand "**" recursively in globs
shopt -s globstar

# --- Source modular configs ---
for f in "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/bashrc.d/*.sh; do
    # shellcheck source=/dev/null
    [[ -r "$f" ]] && source "$f"
done
unset f
