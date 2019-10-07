#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias n='nvim'
alias picocom='picocom --escape=c'
alias p='picocom --escape=c /dev/ttyUSB0'
alias w='curl wttr.in/gdansk'



#PS1='[\u@\h \W]\$ '

#lukesmith promt
export PS1="\[$(tput bold)\]\[$(tput setaf 1)\][\[$(tput setaf 3)\]\u\[$(tput setaf 2)\]@\[$(tput setaf 4)\]\h \[$(tput setaf 5)\]\W\[$(tput setaf 1)\]]\[$(tput setaf 7)\]\\$ \[$(tput sgr0)\]"

source ~/.dotfiles/.fffrc
