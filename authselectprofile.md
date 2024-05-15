# 'authselect check' or 'authselect apply-changes' command throws "[error] Unexpected changes to the configuration were detected"

Environment

Red Hat Enterprise Linux 8

Red Hat Enterprise Linux 9

authselect Issue

When manual changes are performed on /etc/pam.d/password-auth or /etc/pam.d/system-auth 'authselect apply-changes' gives below error.
```ruby
#authselect apply-changes
[error] [/etc/authselect/system-auth] has unexpected content!
[error] [/etc/authselect/password-auth] has unexpected content!
[error] Unexpected changes to the configuration were detected.
[error] Refusing to activate profile unless those changes are removed or overwrite is requested.
```
Some unexpected changes to the configuration were detected. Use 'select' command instead.

# Resolution
## Solution 01

To overwrite the changes --force parameter shall be used, using the current profile selection from the system.

Validate the configuration using authselect check:

```ruby
[root@server]# authselect check
[error] [/etc/authselect/system-auth] has unexpected content!
[error] [/etc/authselect/password-auth] has unexpected content!
Current configuration is not valid. It was probably modified outside authselect.
[root@server]
List the available profiles using authselect list:
```
```ruby
[root@server]# authselect list
- minimal    Local users only for minimal installations
- sssd       Enable SSSD for system authentication (also for local users only)
- winbind    Enable winbind for system authentication
[root@server]
```

To overwrite the changes use --force parameter:
```ruby
[root@server]# authselect select $(authselect current --raw) --force
[error] [/etc/authselect/system-auth] has unexpected content!
[error] [/etc/authselect/password-auth] has unexpected content!
Backup stored at /var/lib/authselect/backups/2023-05-11-04-49-06.rYMf2m
Profile "sssd" was selected.
The following nsswitch maps are overwritten by the profile:
- passwd
- group
- netgroup
- automount
- services
```
Make sure that SSSD service is configured and enabled. See SSSD documentation for more information.

Check the current profile using authselect current:
```ruby
[root@server]# authselect current
Profile ID: sssd
Enabled features: None
[root@server]#
```
Validate the configuration using authselect check:
```ruby
[root@server]# authselect check
Current configuration is valid.
```
## Solution 02

Removing the files under authselect and recreating them with authselect.

Remove the files under /etc/authselect except for custom directory and user-nsswitch.conf:

```ruby
[root@server]# cp -a /etc/authselect /etc/authselect-$(date +%Y-%m%d-%H%M).save
[root@server]# cd /etc/authselect
[root@server]# ls /etc/authselect | egrep -v "custom|user-nsswitch.conf" | xargs rm -rf
```
Recreate the profile using `authselect select profile name':
```ruby
[root@server]# authselect select sssd
Profile "sssd" was selected.
The following nsswitch maps are overwritten by the profile:
- passwd
- group
- netgroup
- automount
- services
```
Make sure that SSSD service is configured and enabled. See SSSD documentation for more information.

Verify the files under /etc/authselect got recreated:

```ruby
[root@server]# ls -ltr /etc/authselect
total 36
-rw-r--r--. 1 root root 1889 May  9 19:33 system-auth
-rw-r--r--. 1 root root 1889 May  9 19:33 password-auth
-rw-r--r--. 1 root root  140 May  9 19:33 fingerprint-auth
-rw-r--r--. 1 root root  140 May  9 19:33 smartcard-auth
-rw-r--r--. 1 root root  397 May  9 19:33 postlogin
-rw-r--r--. 1 root root  923 May  9 19:33 nsswitch.conf
-rw-r--r--. 1 root root  231 May  9 19:33 dconf-db
-rw-r--r--. 1 root root  260 May  9 19:33 dconf-locks
-rw-r--r--. 1 root root    6 May  9 19:33 authselect.conf
```
Verify the current profile using authselect utility:
```ruby
[root@server]# authselect current
Profile ID: sssd
Enabled features: None
```
Root Cause

This issue arises when the PAM stack files are modified manually.

## Diagnostic Steps

Execute 'authselect check' or 'authselect apply-changes' command to diagnose.
```ruby
#authselect apply-changes
[error] [/etc/authselect/system-auth] has unexpected content!
[error] [/etc/authselect/password-auth] has unexpected content!
[error] Unexpected changes to the configuration were detected.
[error] Refusing to activate profile unless those changes are removed or overwrite is requested.
Some unexpected changes to the configuration were detected. Use 'select' command instead.
```
Resource - https://access.redhat.com/solutions/7011856
