#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

# Default programs:
export EDITOR="nvim"
export PAGER="less"
export TERMINAL="alacritty"
export BROWSER="firefox"
export READER="zathura"
export FILE="lf"
export VISUAL="nvim"

# Startx after login
[ "$(tty)" = "/dev/tty1" ] && ! pgrep -x Xorg >/dev/null && exec startx
