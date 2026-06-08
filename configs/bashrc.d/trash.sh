# --- trash-cli safety override ---

# Guard: skip if trash-cli is not installed
command -v trash &>/dev/null || return

# Intercept rm to encourage using trash-cli instead
alias rm='  echo "This is not the command you are looking for."
echo "Use trash-cli instead: https://github.com/andreafrancia/trash-cli"
echo "If you in desperate need of rm use this -> \rm"; false'
