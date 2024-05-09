#!/usr/bin/env bash

{
   l_mname='squashfs' # set module name
   # Check if the module exists on the system
   if [ -z "$(modprobe -n -v "$l_mname" 2>&1 | grep -Pi -- 'h*modprobe:h+FATAL:h+Moduleh+$l_mnameh+noth+foundh+inh+directory')" ]; then
      # Remediate loadable
      l_loadable="$(modprobe -n -v "$l_mname")"
      if [ "$(wc -l <<< "$l_loadable")" -gt '1' ]; then
         l_loadable="$(grep -P -- '(^h*install|b$l_mname)b' <<< "$l_loadable")"
      fi
      if ! grep -Pq -- '^h*install /bin/(true|false)' <<< "$l_loadable"; then
         echo -e " - setting module: $l_mname to be not loadable"
         echo -e "install $l_mname /bin/false" >> "/etc/modprobe.d/$l_mname.conf"
      fi
      # Remediate loaded
      if lsmod | grep "$l_mname" > /dev/null 2>&1; then
         echo -e " - unloading module $l_mname"
         modprobe -r "$l_mname"
      fi
      # Remediate deny list
      if ! modprobe --showconfig | grep -Pq -- '^h*blacklisth+$l_mnameb'; then
         echo -e " - deny listing $l_mname"
         echo -e "blacklist $l_mname" >> "/etc/modprobe.d/$l_mname.conf"
      fi
   else
      echo -e " - Nothing to remediate\n - Module $l_mname doesn't exist on the system"
   fi
}

