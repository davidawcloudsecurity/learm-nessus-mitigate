# learm-nessus-mitigate

## How to append rules to audit/audit.rules
```ruby
Creation of files in /etc/audit/audit.rules depends /etc/audit/rules.d/audit.rules
# Display rules
auditctl -l
# Load rules
augenrules --load; auditctl -l; auditctl -s | grep 'enabled'
# Check if 2 or less. Require restart
auditctl -s | grep 'enabled'

sudo service auditd restart

# Run Policy value to check if rule pass or fail (example)
auditctl -l | /usr/bin/awk '(/^ *-a *always,exit/||/^ *-a *exit,always/) &&/ -F *arch=b32/ &&(/ -F *auid!=unset/||/ -F *auid!=-1/||/ -F *auid!=4294967295/) &&(/ -C *euid!=uid/||/ -C *uid!=euid/) &&/ -S *execve/ &&(/ key= *[!-~]* *$/||/ -k *[!-~]* *$/)' | /usr/bin/awk '{print} END {if (NR != 0) print "pass" ; else print "fail"}'

```
## How to setup hostname
```ruby
hostnamectl status
hostnamectl set-hostname name
```
Resource - https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/networking_guide/sec_configuring_host_names_using_hostnamectl
## How to force logrotate
```ruby
logrotate -vf /etc/logrotate.conf
```
## Compliant ToolKit for Win 10/11/2019
https://www.microsoft.com/en-us/download/details.aspx?id=55319 (Require LGPO.zip)

## Windows admx/adml Resources
This lists represent the key value name you can plug into the registry via regedit

https://learn.microsoft.com/en-us/windows/client-management/mdm/policy-csp-desktopappinstaller

https://github.com/MicrosoftDocs/Managed-Desktop/blob/public/managed-desktop/references/windows-11-policy-settings.md

https://github.com/microsoft/defender-updatecontrols/blob/main/WindowsDefender.admx

https://github.com/MicrosoftDocs/Managed-Desktop/blob/public/managed-desktop/references/windows-11-policy-settings.md

(RPC)

https://www.thewindowsclub.com/switch-network-printing-between-tcp-and-rpc
