# self service passowrd reset
Clone [source repo](https://github.com/larrabee/freeipa-password-reset) and follow install instructions

For troubleshooting look below

# troubleshoot

## Logs
tail -f /home/ldap-passwd-reset/.ipa/log/api.log
tail -f /var/log/httpd/access_log
tail -f /var/log/httpd/error_log

## Ipa user ldap-passwd-reset
- User has valid password & not locked out
- User can reset password via GUI for specific other users (!)
- ldap-passwd-reset can't reset pw for users who are mebmers of default 'admins' group

1. Kerberos ticket
```bash
# get ticket
ipa-getkeytab -p ldap-passwd-reset -k /opt/data/IPAPasswordReset/ldap-passwd-reset.keytab
chown ldap-passwd-reset.ldap-passwd-reset $(ipa -n user-show "ldap-passwd-reset" --raw |grep 'homedirectory' |awk -F':' '{print $2}')
chmod 750 $(ipa -n user-show "ldap-passwd-reset" --raw |grep 'homedirectory' |awk -F':' '{print $2}')

# check ticket
su ldap-passwd-reset
# try login
kinit -kt ldap-passwd-reset.keytab ldap-passwd-reset
klist
```

