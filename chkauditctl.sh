#!/bin/bash

uname -m
read -p "Press enter to continue"

cat <<EOF | sudo tee /etc/audit/rules.d/50-user_emulation.rules
-a always,exit -F arch=b64 -C euid!=uid -F auid!=unset -S execve -k user_emulation
-a always,exit -F arch=b32 -C euid!=uid -F auid!=unset -S execve -k user_emulation
EOF

sudo augenrules --load

if [[ $(auditctl -s | grep 'enabled') =~ '2' ]]; then printf 'Reboot required to load rules\n'; fi

