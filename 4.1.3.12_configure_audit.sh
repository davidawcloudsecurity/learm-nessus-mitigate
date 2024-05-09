#!/bin/bash

# Define the audit rules file
AUDIT_RULES_FILE="/etc/audit/rules.d/50-login.rules"

# Add audit rules to the file
printf '
-w /var/log/lastlog -p wa -k logins
-w /var/run/faillock -p wa -k logins
' | sudo tee -a "$AUDIT_RULES_FILE" > /dev/null

# Merge and load the rules into the active configuration
sudo augenrules --load

# Check if a reboot is required
if [[ $(auditctl -s | grep 'enabled') =~ '2' ]]; then
    printf 'Reboot required to load rules\n'
fi

