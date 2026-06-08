# --- Aliases ---

alias ls='ls --color=auto -F'
alias l='ls -lhF'
alias ll='ls -AlhF'
alias grep='grep --color=auto'

alias sshrs='rsync --exclude=.git --exclude='*cscope*' --info=progress2 --stats -azvh -e "ssh"'
alias rs='rsync --info=progress2 --stats -azvh'

alias dm='sudo dmesg -wH'
