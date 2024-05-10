#!/bin/bash

# Function to check system architecture (64-bit or 32-bit)
check_architecture() {
    arch=$(uname -m)
    if [[ "$arch" == "x86_64" ]]; then
        echo "64-bit"
    elif [[ "$arch" == "i686" || "$arch" == "i386" ]]; then
        echo "32-bit"
    else
        echo "Unsupported architecture"
        exit 1
    fi
}

# Function to create audit rule
create_audit_rule() {
    local UID_MIN=$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)
    if [[ -n "$UID_MIN" ]]; then
        echo "-a always,exit -F path=/usr/sbin/usermod -F perm=x -F auid>=${UID_MIN} -F auid!=-1 -F auid!=unset -k usermod"
    else
        echo "ERROR: Variable 'UID_MIN' is unset."
        exit 1
    fi
}

# Function to create or append audit rule to file
create_audit_rule_file() {
    local rule="$1"
    echo "$rule" >> /etc/audit/rules.d/50-usermod.rules
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
    local arch=$(check_architecture)

    if [[ "$arch" == "64-bit" || "$arch" == "32-bit" ]]; then
        local rule=$(create_audit_rule)
        create_audit_rule_file "$rule"
        load_audit_rules
        check_reboot_required
    else
        echo "$arch"
    fi
}

main

