# --- Sync notes ---

notes_sync() {
    local notes_dir="$HOME/repos/notes"
    local no_push=false

    for arg in "$@"; do
        case $arg in
            --no-push)
                no_push=true
                shift
                ;;
        esac
    done

    pushd "$notes_dir" > /dev/null || return

    echo "PWD: $PWD"
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
        echo "Not a git repository: $notes_dir"
        popd > /dev/null
        return 1
    fi

    if [ "$no_push" = true ]; then
        echo -e "\n--- Skipping all pushes."
    fi

    if [ "$no_push" = false ] && git log --branches --not --remotes | grep -q .; then
        echo -e "\n--- Pushing existing local commits..."
        if ! git push; then
            echo "Error: Failed to push commits."
            popd > /dev/null
            return 1
        fi
    fi

    echo -e "\n--- Pulling changes from remote..."
    if ! git pull --rebase; then
        echo "Error: Failed to pull changes."
        popd > /dev/null
        return 1
    fi

    if git diff --quiet && git diff --cached --quiet && [ -z "$(git ls-files --others --exclude-standard)" ]; then
        echo -e "\nNo new changes."
        popd > /dev/null
        return 0
    fi

    echo -e "\n--- Git status:"
    git status

    echo -e "\n--- Create new commit:"
    git add -A
    git commit -sam "$(date '+%Y-%m-%d: update')"

    if [ "$no_push" = false ]; then
        echo -e "\n--- Pushing new commit:"
        if ! git push; then
            echo "Error: Failed to push new commit."
            popd > /dev/null
            return 1
        fi
    fi

    popd > /dev/null
}

# --- Utility functions (from https://github.com/bahamas10/bash-analysis) ---

# Print the Nth field of each line (default: field 1, separator: space)
# Usage: cat /etc/passwd | field 7 :
field() {
    awk -F "${2:- }" "{ print \$${1:-1} }"
}

# Sum the Nth field of each line
# Usage: cat data | total
total() {
    awk -F "${2:- }" "{ s += \$${1:-1} } END { print s }"
}

# Show frequency count of each unique line
# Usage: cat data | freq
freq() {
    sort | uniq -c | sort -n
}

# Print a statistical summary (min, max, sum, avg) for input data
summarize() {
    local f=${1:-1}
    awk -F "${2:- }" "
    length(\$$f) {
    if (max == \"\")
        max = min = \$$f;
        i += 1;
        sum += \$$f;
        if (\$$f > max)
            max = \$$f
            if (\$$f < min)
                min = \$$f
            }
            END {
            print \"lines\\t\", i;
            print \"min\\t\", min;
            print \"max\\t\", max;
            print \"sum\\t\", sum;
            print \"avg\\t\", sum/i;
        }"
}
