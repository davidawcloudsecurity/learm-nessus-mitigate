#!/bin/bash

# Function to check if system is 64-bit or 32-bit
check_bit() {
    arch=$(uname -m)
    if [[ "$arch" == "x86_64" ]]; then
        return 64
    elif [[ "$arch" == "i686" || "$arch" == "i386" ]]; then
        return 32
    else
        return 0
    fi
}

# Function to create audit rule file
create_audit_rule_file() {
    cat > /etc/audit/rules.d/50-perm_chng.rules <<EOF
# Audit rule for monitoring setfacl command
$(get_audit_rule)
EOF
}

# Function to get the audit rule based on system bitness
get_audit_rule() {
    local UID_MIN=$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)
    if [[ -n "$UID_MIN" ]]; then
        echo "-a always,exit -F path=/usr/bin/setfacl -F perm=x -F auid>=${UID_MIN} -F auid!=-1 -F auid!=unset -k perm_chng"
    else
        echo "ERROR: Variable 'UID_MIN' is unset."
    fi
}

# Function to load audit rules
load_audit_rules() {
    augenrules --load
}

# Function to check if reboot is required
check_reboot_required() {
    if [[ $(auditctl -s | grep 'enabled') =~ '2' ]]; then
        echo "Reboot required to load rules"
    fi
}

# Main function
main() {
    check_bit
    bitness=$?
    
    if [[ "$bitness" == 64 ]]; then
        create_audit_rule_file
        load_audit_rules
        check_reboot_required
    elif [[ "$bitness" == 32 ]]; then
        create_audit_rule_file
        load_audit_rules
        check_reboot_required
    else
        echo "Unsupported architecture"
    fi
}

main

