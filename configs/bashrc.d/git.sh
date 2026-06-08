# --- Git aliases ---

# Guard: skip if git is not installed
command -v git &>/dev/null || return

alias gds='git diff --staged'
alias gll="git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)'"
alias gs='find . -name ".git" -type d -print0 | while IFS= read -r -d "" dir; do (cd "${dir%/*}" && echo "REPO: $(pwd)" && git status && echo "---------------------------------------------------"); done'
alias gp='find . -name ".git" -type d -print0 | while IFS= read -r -d "" dir; do (cd "${dir%/*}" && echo "REPO: $(pwd)" && git pull && echo "---------------------------------------------------"); done'
alias gcm='git commit'
alias gcma='git commit --amend'
alias grbc='git rebase --continue'
alias gcpc='git cherry-pick --continue'
alias gsl='git stash list --pretty=format:"%gd: %Cred%h%Creset %Cgreen[%ar]%Creset %s"'
