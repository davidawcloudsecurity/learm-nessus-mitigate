#!/bin/bash

# Prompt the user for the custom profile name
read -p "Enter the custom profile name: " profile_name

# Construct the authselect command with the custom pro:wfile name and default options
authcreate_command="authselect create-profile $profile_name -b sssd --symlink-meta"
authselect_command="authselect select custom/$profile_name with-sudo with-faillock without-nullok --force"

# Execute the authselect command
echo "Executing: $authcreate_command"
$authcreate_command
echo "Executing: $authselect_command"
$authselect_command

