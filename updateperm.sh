#!/usr/bin/env bash

{
  # Variables initialization
  operation=''
  output=''
  uid_min=$(awk '/^s*UID_MIN/{print $2}' /etc/login.defs)

  # Function to fix file permissions and ownership
  fix_file_permissions() {
    operation=''
    file_user='root'
    file_group='root'

    if [ $(( $mode & $perm_mask )) -gt 0 ]; then
      operation="$operation
  - Mode: $mode should be $maxperm or more restrictive
   - Removing excess permissions"
      chmod "$permissions" "$file"
    fi

    if [[ ! "$user" =~ $allowed_user ]]; then
      operation="$operation
  - Owned by: $user and should be owned by ${allowed_user//|/ or }
   - Changing ownership to: $file_user"
      chown "$file_user" "$file"
    fi

    if [[ ! "$group" =~ $allowed_group ]]; then
      operation="$operation
  - Group owned by: $group and should be group owned by ${allowed_group//|/ or }
   - Changing group ownership to: $file_group"
      chgrp "$file_group" "$file"
    fi

    [ -n "$operation" ] && output="$output
 - File: $file is:$operation
"
  }

  unset file_array && file_array=() # Clear and initialize array

  # Loop to create array with stat of files that could possibly fail one of the audits
  while IFS= read -r -d $'\0' file; do
    [ -e "$file" ] && file_array+=("$(stat -Lc '%n^%#a^%U^%u^%G^%g' "$file")")
  done < <(find -L /var/log -type f \( -perm /0137 -o ! -user root -o ! -group root \) -print0)

  while IFS='^' read -r file mode user uid group gid; do
    filename=$(basename "$file")
    case "$filename" in
      lastlog | lastlog.* | wtmp | wtmp.* | wtmp-* | btmp | btmp.* | btmp-* | README)
        perm_mask='0113'
        maxperm=$(printf '%o' $(( 0777 & ~$perm_mask)) )
        permissions='ug-x,o-wx'
        allowed_user='root'
        allowed_group='(root|utmp)'
        fix_file_permissions
        ;;
      secure | auth.log | syslog | messages)
        perm_mask='0137'
        maxperm=$(printf '%o' $(( 0777 & ~$perm_mask)) )
        permissions='u-x,g-wx,o-rwx'
        allowed_user='(root|syslog)'
        allowed_group='(root|adm)'
        fix_file_permissions
        ;;
      SSSD | sssd)
        perm_mask='0117'
        maxperm=$(printf '%o' $(( 0777 & ~$perm_mask)) )
        permissions='ug-x,o-rwx'
        allowed_user='(root|SSSD)'
        allowed_group='(root|SSSD)'
        fix_file_permissions
        ;;
      gdm | gdm3)
        perm_mask='0117'
        permissions='ug-x,o-rwx'
        maxperm=$(printf '%o' $(( 0777 & ~$perm_mask)) )
        allowed_user='root'
        allowed_group='(root|gdm|gdm3)'
        fix_file_permissions
        ;;
      *.journal | *.journal~)
        perm_mask='0137'
        maxperm=$(printf '%o' $(( 0777 & ~$perm_mask)) )
        permissions='u-x,g-wx,o-rwx'
        allowed_user='root'
        allowed_group='(root|systemd-journal)'
        fix_file_permissions
        ;;
      *)
        perm_mask='0137'
        maxperm=$(printf '%o' $(( 0777 & ~$perm_mask)) )
        permissions='u-x,g-wx,o-rwx'
        allowed_user='(root|syslog)'
        allowed_group='(root|adm)'
        if [ "$uid" -lt "$uid_min" ] && [ -z "$(awk -v grp="$group" -F: '$1==grp {print $4}' /etc/group)" ]; then
          if [[ ! "$user" =~ $allowed_user ]]; then
            allowed_user="(root|syslog|$user)"
          fi
          if [[ ! "$group" =~ $allowed_group ]]; then
            test=''
            while read -r du_id; do
              [ -n "$uid_min" ] && [ "$du_id" -ge "$uid_min" ] && test=failed
#              [ "$du_id" -ge "$uid_min" ] && test=failed
            done <<< "$(awk -F: '$4==""$gid"" {print $3}' /etc/passwd)"
            [ "$test" != "failed" ] && allowed_group="(root|adm|$group)"
          fi
        fi
        fix_file_permissions
        ;;
    esac
  done <<< "$(printf '%s\n' "${file_array[@]}")"

  unset file_array # Clear array

  # If all files passed, then we report no changes
  if [ -z "$output" ]; then
    printf -- "- All files in '/var/log/' have appropriate permissions and ownership\n  - No changes required\n\n"
  else
    # Print report of changes
    printf -- "%s\n" "$output"
  fi
}
