#!/usr/bin/env bash

l_mname='tipc' # set module name

# Check if the module is loaded
if lsmod | grep "$l_mname" &> /dev/null; then
    echo "$l_mname module is loaded."
else
    echo "$l_mname module is not loaded."
fi
