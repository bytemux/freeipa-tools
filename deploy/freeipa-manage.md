# search
```bash
## -s     one|base|children|sub
## -x     simple auth
## -LLL   ldif output

# find user
ldapsearch -x -b "dc=int,dc=domainname,dc=com" -LLL -D "cn=Directory Manager" -W  | grep "bind-openshift"
ldapsearch -x -b "dc=int,dc=domainname,dc=com" -LLL -D "cn=Directory Manager" -y rootcred.txt  | grep "bind-openshift"

# get all user attributes
ldapsearch -x -b "uid=username,cn=users,cn=accounts,dc=int,dc=domainname,dc=com" -LLL -D "cn=Directory Manager" -y rootcred.txt
ldapsearch -x -b "uid=username,cn=users,cn=accounts,dc=int,dc=domainname,dc=com" -LLL -D "uid=ldap-passwd-reset,cn=users,cn=accounts,dc=int,dc=domainname,dc=com" -y temp.txt
ldapsearch -x -b "uid=username,cn=users,cn=accounts,dc=int,dc=domainname,dc=com" -LLL -D "uid=bind-gcds,cn=users,cn=accounts,dc=int,dc=domainname,dc=com" -y gcds.txt

# get cn=config
ldapsearch -x -b "cn=config" -s base -LLL -D "cn=Directory Manager" -y rootcred.txt | grep passwordStorageScheme
ldapsearch -x -b "cn=ipa_pwd_extop,cn=plugins,cn=config"  -LLL -D "cn=Directory Manager" -y rootcred.txt
```

# get ca cert
openssl s_client -showcerts -connect ipa-01.domainname.com:636 </dev/null


# manage users
```bash
# add
ipa user-add $user
ipa passwd $user
# activate password if expired
kinit $user

# Unlock after failed login attemts
ipa user-status $user
ipa user-unlock $user

```

# verify password
```bash
echo $userPassword | base64 -d
slappasswd -h "{SHA}"

```
