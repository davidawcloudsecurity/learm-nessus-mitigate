#!/bin/bash

# Check if X11Forwarding no is already set in sshd_config
check_sshd_config() {
    if grep -q "^X11Forwarding\s*no" /etc/ssh/sshd_config; then
        echo "X11Forwarding is already set to no in /etc/ssh/sshd_config"
    else
        echo "X11Forwarding no" | sudo tee -a /etc/ssh/sshd_config >/dev/null
        echo "X11Forwarding parameter added/updated in /etc/ssh/sshd_config"
    fi
}

# Main function
main() {
    check_sshd_config
}

main

