#!/bin/bash

# Function to check if NOPASSWD directive is present in sudoers file
check_sudoers_file() {
    local sudoers_files=("/etc/sudoers" "/etc/sudoers.d/ssm-agent-users" "/etc/sudoers.d/90-cloud-init-users")
    local non_compliant_files=()

    for file in "${sudoers_files[@]}"; do
        if grep -q "^[^#]*NOPASSWD" "$file"; then
            non_compliant_files+=("$file")
        fi
    done

    if [[ ${#non_compliant_files[@]} -eq 0 ]]; then
        echo "All sudoers files are compliant."
    else
        echo "Non-compliant file(s):"
        for file in "${non_compliant_files[@]}"; do
            echo "  $file - regex '^[^#]*NOPASSWD' found"
            grep -E "^[^#]*NOPASSWD" "$file" | sed 's/^/# /'
        done
    fi
}

# Main function
main() {
    check_sudoers_file
}

main

