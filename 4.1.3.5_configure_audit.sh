#!/bin/bash

# Check system architecture
ARCH=$(getconf LONG_BIT)

# Define audit rules based on architecture
if [ "$ARCH" -eq 64 ]; then
    AUDIT_RULES='-a always,exit -F arch=b64 -S sethostname,setdomainname -k system-locale
                  -w /etc/issue -p wa -k system-locale
                  -w /etc/issue.net -p wa -k system-locale
                  -w /etc/hosts -p wa -k system-locale
                  -w /etc/sysconfig/network -p wa -k system-locale
                  -w /etc/sysconfig/network-scripts/ -p wa -k system-locale'
elif [ "$ARCH" -eq 32 ]; then
    AUDIT_RULES='-a always,exit -F arch=b32 -S sethostname,setdomainname -k system-locale
                  -w /etc/issue -p wa -k system-locale
                  -w /etc/issue.net -p wa -k system-locale
                  -w /etc/hosts -p wa -k system-locale
                  -w /etc/sysconfig/network -p wa -k system-locale
                  -w /etc/sysconfig/network-scripts/ -p wa -k system-locale'
else
    echo "Unsupported architecture: $ARCH bits"
    exit 1
fi

# Step 1: Add audit rules to the file
printf '%s\n' "$AUDIT_RULES" | sudo tee -a /etc/audit/rules.d/50-system_local.rules > /dev/null

# Step 2: Merge and load the rules into the active configuration
sudo augenrules --load

# Step 3: Check if a reboot is required
if [[ $(auditctl -s | grep 'enabled') =~ '2' ]]; then
    printf 'Reboot required to load rules\n'
fi

