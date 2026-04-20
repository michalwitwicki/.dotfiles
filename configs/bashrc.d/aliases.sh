# --- Aliases ---

alias v='nvim'
alias ls='ls --color=auto -F'
alias l='ls -lhF'
alias ll='ls -AlhF'
alias grep='grep --color=auto'

alias sshrs='rsync --exclude=.git --exclude='*cscope*' --info=progress2 --stats -azvh -e "ssh"'
alias rs='rsync --info=progress2 --stats -azvh'

alias dm='sudo dmesg -wH'

# warning to use trash-cli instead of rm
alias rm='  echo "This is not the command you are looking for."
echo "Use trash-cli instead: https://github.com/andreafrancia/trash-cli"
echo "If you in desperate need of rm use this -> \rm"; false'

# git
alias gds='git diff --staged'
alias gll="git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)'"
alias gs='find . -name ".git" -type d | while read dir ; do sh -c "cd $dir/../ && printf "REPO:" && pwd && git status && echo "---------------------------------------------------"" ; done'
alias gp='find . -name ".git" -type d | while read dir ; do sh -c "cd $dir/../ && printf "REPO:" && pwd && git pull && echo "---------------------------------------------------"" ; done'
alias gcm='git commit'
alias gcma='git commit --amend'
alias grbc='git rebase --continue'
alias gcpc='git cherry-pick --continue'
alias gsl='git stash list --pretty=format:"%gd: %Cred%h%Creset %Cgreen[%ar]%Creset %s"'

# fzf shortcuts
alias ff='fzf_find_file'
alias fs='fzf_find_grep'

# zip / unzip
alias zp='function _zp(){ zip -rv "$(basename "$1").zip" "$1"; }; _zp'
alias uzp='function _uzp(){ unzip "$1" -d "${1%.zip}"; }; _uzp'
