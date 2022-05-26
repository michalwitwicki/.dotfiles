#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# launch tmux session on bash startup
if command -v tmux &> /dev/null && [ -z "$TMUX" ] && [ -n "$DISPLAY" ]; then
    tmux attach -t default || tmux new -s default
fi

alias picocom='picocom --escape=c'
alias p='picocom --escape=c /dev/ttyUSB0'
alias w='curl wttr.in/gdansk'
alias grep='grep --color=auto'
alias ls='ls --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias gs='git status'
alias gl="git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold
green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all"

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

parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}
#export PS1="\[$(tput bold)\]\[$(tput setaf 1)\][\[$(tput setaf 3)\]\u\[$(tput setaf 2)\]@\[$(tput setaf 4)\]\h \[$(tput setaf 5)\]\W\[$(tput setaf 1)\]]\[$(tput setaf 7)\]\\$ \[$(tput sgr0)\]"
export PS1="\[$(tput bold)\]\[$(tput setaf 1)\][\[$(tput setaf 2)\]\t \[$(tput setaf 3)\]\W\[$(tput setaf 1)\]]\[$(tput setaf 5)\]\$(parse_git_branch)\[$(tput setaf 7)\]\\$ \[$(tput sgr0)\]"

# Add $HOME/.local/bin to PATH
export PATH="$PATH:$HOME/.local/bin"

# Warning to use trash-cli instead of rm
alias rm='  echo "This is not the command you are looking for."
            echo "Use trash-cli instead: https://github.com/andreafrancia/trash-cli"
            echo "If you in desperate need of rm use this -> \rm"; false'

# cd on exit for lf file manager
LFCD="$HOME/.config/lf/lfcd.sh"
if [ -f "$LFCD" ]; then
    source "$LFCD"
    alias lf='lfcd'
fi

