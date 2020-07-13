# Seafile in Docker
```bash
apt update && apt install -y nano
cd /usr/local/share/ca-certificates/; mkdir ipa; nano ipa/ldap-ca.crt
update-ca-certificates
docker-compose restart
```


```conf
[LDAP]
HOST = ldaps://ipa-01.int.domainname.com/
BASE = cn=users,cn=accounts,dc=int,dc=domainname,dc=com
USER_DN = uid=binduser,cn=users,cn=accounts,dc=int,dc=domainname,dc=com
PASSWORD = INSERT_PASSWORD
LOGIN_ATTR = uid
FILTER = memberOf=cn=all-employees,cn=groups,cn=accounts,dc=int,dc=domainname,dc=com
```
