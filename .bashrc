#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# launch tmux session on bash startup
if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
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


# cd on exit for lf file manager
LFCD="$HOME/.config/lf/lfcd.sh"
if [ -f "$LFCD" ]; then
    source "$LFCD"
    alias lf='lfcd'
fi

#tracpoint settings
#xinput --set-prop 'TPPS/2 IBM TrackPoint' 'libinput Accel Speed' -0.3
xinput --set-prop 'TPPS/2 IBM TrackPoint' 'Device Enabled' 0

#Touchpad settings
xinput --set-prop 'Synaptics TM3075-002' 'libinput Natural Scrolling Enabled' 1
xinput --set-prop 'Synaptics TM3075-002' 'libinput Accel Speed' -0.2
xinput --set-prop 'Synaptics TM3075-002' 'libinput Tapping Enabled' 1

