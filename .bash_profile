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

# Trackpoint settings
#xinput --set-prop 'TPPS/2 IBM TrackPoint' 'libinput Accel Speed' -0.3
xinput --set-prop 'TPPS/2 IBM TrackPoint' 'Device Enabled' 0

# Touchpad settings
xinput --set-prop 'Synaptics TM3075-002' 'libinput Natural Scrolling Enabled' 1
xinput --set-prop 'Synaptics TM3075-002' 'libinput Accel Speed' -0.2
xinput --set-prop 'Synaptics TM3075-002' 'libinput Tapping Enabled' 1

# Startx after login
[ "$(tty)" = "/dev/tty1" ] && ! pgrep -x Xorg >/dev/null && exec startx
