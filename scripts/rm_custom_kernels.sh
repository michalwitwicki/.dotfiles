#!/bin/bash

selected_kernel=$(\
    sudo grubby --info=ALL \
    | grep kernel \
    | awk -F= '{print $2}' \
    | tr -d '"' \
    | fzf --multi)

if [[ -z "$selected_kernel" ]]; then
    echo "No kernel selected."
    exit 1
fi

current_kernel=$(uname -r)
commands=()

while IFS= read -r kernel; do
    kernel_path=$(echo "$kernel")
    kernel_name=$(echo "$kernel" | awk -F/ '{print $NF}')

    if [[ "$kernel_name" == *"rescue"* ]]; then
        echo "Warning: Skipping rescue kernel: '$kernel_name'"
        continue
    fi

    if [[ "$kernel_name" == *"$current_kernel"* ]]; then
        echo "Warning: Skipping current kernel: '$kernel_name'"
        continue
    fi

    commands+=("sudo grubby --remove-kernel=$kernel_path")
    commands+=("sudo find /lib/modules -name '*$kernel_name*' -exec rm -rf {} +")
    commands+=("sudo find /boot -name '*$kernel_name*' -exec rm -rf {} +")

done <<< "$selected_kernel"

# Print commands for confirmation
echo "The following commands will be executed:"
printf "%s\n" "${commands[@]}"

# Ask for confirmation
read -p "Do you want to proceed? (y/N): " confirm
if [[ "$confirm" != "y" ]]; then
    echo "Aborted."
    exit 1
fi

# Execute commands
for cmd in "${commands[@]}"; do
    eval "$cmd"
done
