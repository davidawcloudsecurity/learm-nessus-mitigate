# learm-nessus-mitigate

## How to append rules to audit/audit.rules
```ruby
Creation of files in /etc/audit/audit.rules depends /etc/audit/rules.d/audit.rules
# Display rules
auditctl -l
# Load rules
augenrules --load
# Check if 2 or less. Require restart
auditctl -s | grep 'enabled'
# Run Policy value to check if rule pass or fail
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
