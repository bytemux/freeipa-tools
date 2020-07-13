# Google Cloud Directory Sync
https://support.google.com/a/answer/9089736?hl=en
https://serverfault.com/questions/852604/need-help-setting-up-google-cloud-directory-sync-with-ad-using-secure-ldap

# Setup
```bash
# add to cacerts
cd /opt/GoogleCloudDirSync/jre
cp ./lib/security/cacerts{,.bak}
bin/keytool -keystore lib/security/cacerts -storepass changeit -import -file ./ldap-ca.crt -alias mydc

# disable crl check
cd /opt/GoogleCloudDirSync/
data="-Dcom.sun.net.ssl.checkRevocation=false\n-Dcom.sun.security.enableCRLDP=false\n"
echo -en $data >> ./sync-cmd.vmoptions
echo -en $data >> ./config-manager.vmoptions

# call with config
## test
/opt/GoogleCloudDirSync/sync-cmd -c /root/gcds/gcds-domainname.com.xml
## sync
/opt/GoogleCloudDirSync/sync-cmd -a -c /root/gcds/gcds-domainname.com.xml

```

# add IPA read userPassword permissions
```bash
# add permission
attribute:      userPassword
granted rights: read,search,compare
target dn:      cn=users,cn=accounts,dc=int,dc=domainname,dc=com
extra filter:   (!(memberOf=cn=admins,cn=groups,cn=accounts,dc=int,dc=domainname,dc=com))

# add privilege
# add role, add user "bind-gcds" to role
````

# user sync rule
```bash
## rule
(&(objectClass=inetorgperson)(memberOf=cn=all-employees,cn=groups,cn=accounts,dc=int,dc=domainname,dc=com))
## basedn
cn=users,cn=accounts,dc=int,dc=domainname,dc=com
```

# groups sync rule
```bash
## rule
(&(objectClass=ipausergroup)(memberOf=cn=all-gcds,cn=groups,cn=accounts,dc=int,dc=domainname,dc=com))
## basedn
cn=groups,cn=accounts,dc=int,dc=domainname,dc=com
```

# run sync from cmd
```bash
# --deletelimits   = ignore limits
/opt/GoogleCloudDirSync/sync-cmd --apply --oneinstance --config /sd/proj/repos/git.domainname.com/sso/gcds/gcds-domainname.com.xml
```

---

# [Move config to another machine](https://support.google.com/a/answer/6162404)
```bash
# on local
file_list="gcds-domainname.com.xml /home/domainname/passwordTimestampCache.tsv /home/domainname/nonAddressPrimaryKeyFile.tsv $HOME/.java/.userPrefs/com/google/usersyncapp/util/prefs.xml"
for i in $file_list; do scp $i domainname@ipa-01.int.domainname.com:/home/domainname; done

# on remote
file_list="/home/domainname/gcds-domainname.com.xml /home/domainname/passwordTimestampCache.tsv /home/domainname/nonAddressPrimaryKeyFile.tsv /home/domainname/prefs.xml"
for i in $file_list; do chown root:root $i && chmod 660 $i && ls -lah $i; done
sed -i 's#/home/domainname#/root/gcds#g' /home/domainname/gcds-domainname.com.xml
## move to root
mkdir -p /root/gcds; for i in $file_list; do mv $i /root/gcds; done

## add crontab
echo "*/5 * * * * root /opt/GoogleCloudDirSync/sync-cmd --oneinstance --apply --config /root/gcds/gcds-domainname.com.xml; find /var/log/gcds/* -name "*.log" -mtime +3 -type f -exec rm {} +;" >> /etc/crontab

## checkout logs
/var/log/gcds/gcds_sync.#{timestamp}.log

```

# Forbid changing password via Google
https://support.google.com/a/answer/2611842?hl=en&authuser=1
It's convenient to setup redirect to the help page hosted on Google Sites
