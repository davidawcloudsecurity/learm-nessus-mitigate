#!/bin/bash

# Function to fix specific configuration
fix_configuration() {
    local config_file=$1
    local regex=$2
    local expected_line=$3

    if grep -qE "$regex" "$config_file"; then
        echo "Compliant: $expected_line"
    else
        echo "Fixing $config_file..."
        echo "$expected_line" | sudo tee -a "$config_file" > /dev/null
        echo "Configuration fixed in $config_file"
    fi
}

# Main script

# Fix configurations
fix_configuration "/etc/rsyslog.conf" "^[\s]*\*\.emerg" "*.emerg                                                 :omusrmsg:*"
fix_configuration "/etc/rsyslog.conf" "^[\s]*cron\.*" "cron.*                                                  /var/log/cron"
fix_configuration "/etc/rsyslog.conf" "^[\s]*mail\.\*" "mail.*                                                  -/var/log/mail"
fix_configuration "/etc/rsyslog.conf" "^[\s]*\*\.warning;.*\=err" "*.=warning;*.=err                       -/var/log/warn"
fix_configuration "/etc/rsyslog.conf" "^[\s]*\*.\crit" "*.crit                                   /var/log/warn"
fix_configuration "/etc/rsyslog.conf" "^[\s]*\*.\*;mail.none;news.none" "*.*;mail.none;news.none                 -/var/log/messages"
fix_configuration "/etc/rsyslog.conf" "^[\s]*local[0-7]\.*" "local0,local1.*                         -/var/log/localmessages"
fix_configuration "/etc/rsyslog.conf" "^[\s]*local[0-7]\.*" "local2,local3.*                         -/var/log/localmessages"
fix_configuration "/etc/rsyslog.conf" "^[\s]*local[0-7]\.*" "local4,local5.*                         -/var/log/localmessages"
fix_configuration "/etc/rsyslog.conf" "^[\s]*local[0-7]\.*" "local6,local7.*                         -/var/log/localmessages"

# Fix configurations in rsyslog.d/*.conf files
for file in /etc/rsyslog.d/*.conf; do
    if [ -f "$file" ]; then
        fix_configuration "$file" "^[\s]*\*\.emerg" "*.emerg                                                 :omusrmsg:*"
        fix_configuration "$file" "^[\s]*cron\.*" "cron.*                                                  /var/log/cron"
        fix_configuration "$file" "^[\s]*mail\.\*" "mail.*                                                  -/var/log/mail"
        fix_configuration "$file" "^[\s]*\*\.warning;.*\=err" "*.=warning;*.=err                       -/var/log/warn"
        fix_configuration "$file" "^[\s]*\*.\crit" "*.crit                                   /var/log/warn"
        fix_configuration "$file" "^[\s]*\*.\*;mail.none;news.none" "*.*;mail.none;news.none                 -/var/log/messages"
        fix_configuration "$file" "^[\s]*local[0-7]\.*" "local0,local1.*                         -/var/log/localmessages"
        fix_configuration "$file" "^[\s]*local[0-7]\.*" "local2,local3.*                         -/var/log/localmessages"
        fix_configuration "$file" "^[\s]*local[0-7]\.*" "local4,local5.*                         -/var/log/localmessages"
        fix_configuration "$file" "^[\s]*local[0-7]\.*" "local6,local7.*                         -/var/log/localmessages"
    fi
done

# Restart rsyslog service
sudo systemctl restart rsyslog
echo "rsyslog service restarted"

