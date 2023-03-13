#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# launch tmux session on bash startup
if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
  tmux a -t default || exec tmux new -s default && exit;
fi

# user specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

export EDITOR=nvim

alias picocom='picocom --escape=c'
alias grep='grep --color=auto'
alias ls='ls --color=auto'
alias ll='ls -alF'
alias gs='git status'
alias gl="git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold
green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)'"

alias gas='find . -name ".git" -type d | while read dir ; do sh -c "cd $dir/../ && echo "-----------------" && pwd && git status" ; done'
alias gap='find . -name ".git" -type d | while read dir ; do sh -c "cd $dir/../ && echo "-----------------" && pwd && git pull" ; done'

# warning to use trash-cli instead of rm
alias rm='  echo "This is not the command you are looking for."
            echo "Use trash-cli instead: https://github.com/andreafrancia/trash-cli"
            echo "If you in desperate need of rm use this -> \rm"; false'

parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}
export PS1="\[$(tput bold)\]\[$(tput setaf 1)\][\[$(tput setaf 2)\]\t \[$(tput setaf 3)\]\W\[$(tput setaf 1)\]]\[$(tput setaf 5)\]\$(parse_git_branch)\[$(tput setaf 7)\]\\$ \[$(tput sgr0)\]"

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

# cd on exit for fff file manager
f() {
    fff "$@"
    cd "$(cat "${XDG_CACHE_HOME:=${HOME}/.cache}/fff/.fff_d")"
}

