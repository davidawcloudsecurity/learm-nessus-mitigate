#!/bin/bash

# Define the audit rules file
AUDIT_RULES_FILE="/etc/audit/rules.d/50-chcon.rules"

# Check system architecture
ARCH=$(getconf LONG_BIT)

# Define UID_MIN
UID_MIN=$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)

# Check if UID_MIN is set
if [ -z "${UID_MIN}" ]; then
    echo "ERROR: Variable 'UID_MIN' is unset."
    exit 1
fi

# Define the audit rules based on system architecture
if [ "$ARCH" -eq 64 ]; then
    AUDIT_RULES="-a always,exit -F path=/usr/bin/chcon -F perm=x -F auid>=${UID_MIN} -F auid!=unset -k perm_chng"
elif [ "$ARCH" -eq 32 ]; then
    AUDIT_RULES="-a always,exit -F path=/usr/bin/chcon -F perm=x -F auid>=${UID_MIN} -F auid!=unset -k perm_chng"
else
    echo "Unsupported architecture: $ARCH bits"
    exit 1
fi

# Add audit rules to the file
printf '%s\n' "$AUDIT_RULES" | sudo tee -a "$AUDIT_RULES_FILE" > /dev/null

# Merge and load the rules into the active configuration
sudo augenrules --load

# Check if a reboot is required
if [[ $(auditctl -s | grep 'enabled') =~ '2' ]]; then
    printf 'Reboot required to load rules\n'
fi

