#!/usr/bin/env bash

# Edit /etc/security/pwquality.conf for password length and complexity
sed -i 's/^minlen = .*/minlen = 14/' /etc/security/pwquality.conf
sed -i 's/^minclass = .*/minclass = 4/' /etc/security/pwquality.conf
sed -i 's/^dcredit = .*/dcredit = -1/' /etc/security/pwquality.conf
sed -i 's/^ucredit = .*/ucredit = -1/' /etc/security/pwquality.conf
sed -i 's/^ocredit = .*/ocredit = -1/' /etc/security/pwquality.conf
sed -i 's/^lcredit = .*/lcredit = -1/' /etc/security/pwquality.conf

for fn in system-auth password-auth; do
  file="/etc/authselect/$(head -1 /etc/authselect/authselect.conf | grep 'custom/')/$fn"
  if ! grep -Pq -- '^[\h]*password[\h]+requisite[\h]+pam_pwquality\.so([\h]+[^#\r]+)?[\h]+.*enforce_for_root\b.*$' "$file"; then
    sed -ri 's/^[\s]*(password[\s]+requisite[\s]+pam_pwquality\.so)(.*)$/\1 enforce_for_root/' "$file"
  fi
  if grep -Pq -- '^[\h]*password[\h]+requisite[\h]+pam_pwquality\.so([\h]+[^#\r]+)?[\h]+retry=([4-9]|[1-9][0-9]+)\b.*$' "$file"; then
    sed -ri '/pwquality/s/retry=[0-9]+/retry=3/' "$file"
  elif ! grep -Pq -- '^[\h]*password[\h]+requisite[\h]+pam_pwquality\.so([\h]+[^#\r]+)?[\h]+retry=d\b.*$' "$file"; then
    sed -ri 's/^[\s]*(password[\s]+requisite[\s]+pam_pwquality\.so)(.*)$/\1 retry=3/' "$file"
  fi
done
authselect apply-changes

