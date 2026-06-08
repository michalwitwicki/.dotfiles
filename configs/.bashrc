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

# typo correction for directory names in cd and tab completion
shopt -s cdspell
shopt -s dirspell

# save multi-line commands as one history entry
shopt -s cmdhist

# timestamps in history ("history" output shows date/time)
HISTTIMEFORMAT="%F %T "

# exclude noisy commands from history
HISTIGNORE="history"

# sync history across all open terminals in real-time
PROMPT_COMMAND="history -a; history -c; history -r"

# disable Ctrl+S terminal freeze (XON/XOFF flow control)
stty -ixon 2>/dev/null

# bash-completion: safe to source even if already sourced system-wide (no-op if missing)
[ -f /usr/share/bash-completion/bash_completion ] && source /usr/share/bash-completion/bash_completion

# --- Source modular configs ---
for f in "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/bashrc.d/*.sh; do
    # shellcheck source=/dev/null
    [[ -r "$f" ]] && source "$f"
done
unset f
