#!/bin/bash

# Prompt user for file path
read -p "Enter the path to the text file: " file_path

# Check if the file exists
if [ ! -f "$file_path" ]; then
    echo "File not found!"
    exit 1
fi

# Perform the replacement using sed
sed -i 's/gpgcheck/repo_gpgcheck/g' "$file_path"

echo "Replacement completed."
