#!/usr/bin/env bash

l_mname='tipc' # set module name

# Check if the module exists on the system
if ! modinfo "$l_mname" &> /dev/null; then
    echo -e " - Nothing to remediate\\n - Module $l_mname doesn't exist on the system"
    exit 0
fi

# Remediate loadable
l_loadable="$(modprobe -n -v "$l_mname" 2>&1)"
if [[ $(wc -l <<< "$l_loadable") -gt 1 ]]; then
    l_loadable="$(grep -P '(^h*install|b'"$l_mname"'b)' <<< "$l_loadable")"
fi

if ! grep -Pq '^h*install /bin/(true|false)' <<< "$l_loadable"; then
    echo -e " - setting module: $l_mname to be not loadable"
    echo -e "install $l_mname /bin/false" >> "/etc/modprobe.d/$l_mname.conf"
fi

# Remediate loaded
if lsmod | grep "$l_mname" &> /dev/null; then
    echo -e " - unloading module $l_mname"
    modprobe -r "$l_mname"
fi

# Remediate deny list
if ! modprobe --showconfig | grep -Pq '^h*blacklist +'"$l_mname"'\b'; then
    echo -e " - deny listing $l_mname"
    echo -e "blacklist $l_mname" >> "/etc/modprobe.d/$l_mname.conf"
fi
