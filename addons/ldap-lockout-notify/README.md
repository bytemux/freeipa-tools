# Install
```bash
yum install -y pwgen

export svc_name="ldap-lockout-notify"

# Setup ipa user
ipa -n user-add $svc_name --first="$svc_name" --last="$svc_name" --password-expiration="2050-01-01Z" --password "$(pwgen -1 --capitalize --numerals --secure --ambiguous 32)"
ipa role-add-member "User Administrator" --users="ldap-lockout-notify"

# Prepare script dir
mkdir -p /opt/$svc_name; chown -R $svc_name:$svc_name /opt/$svc_name

# Get keytab for "ldap-passwd-reset"
su $svc_name; ipa-getkeytab -p $svc_name -k /opt/$svc_name/$svc_name.keytab; exit

# Copy script
nano /opt/$svc_name/$svc_name.sh; chmod ug+x /opt/$svc_name/$svc_name.sh

# Setup log
mkdir /var/log/$svc_name; chown -R $svc_name:$svc_name /var/log/$svc_name
nano /etc/logrotate.d/$svc_name

# Setup service
nano /usr/lib/systemd/system/$svc_name.service; systemctl enable $svc_name; systemctl restart $svc_name; systemctl status $svc_name;


```

# Troubleshoot
```bash
# 1. logs
journalctl -fu ldap-lockout-notify
tail -f /var/log/ldap-lockout-notify/ldap-lockout-notify.log

# Check ticket content
klist -t -k  /opt/$svc_name/$svc_name.keytab
# Debig in script #klist
```
