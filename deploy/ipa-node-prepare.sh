#!/bin/bash
root_dn="dc=int,dc=domainname,dc=com"

# SECURITY
# forbid unencrypted bind. Default is "off"
ldapmodify -x -D "cn=Directory Manager" -y rootcred.txt  << EOF
dn: cn=config
changetype: modify
replace: nsslapd-require-secure-binds
nsslapd-require-secure-binds: on
EOF
ldapsearch -x -b "cn=config" -s base -LLL -D "cn=Directory Manager" -y rootcred.txt | grep nsslapd-require-secure-binds
# restart is required
systemctl restart ipa


# NOTE: this options do not work with FreeIPA, version: 4.6.5
# nsslapd-minssf: 128
# sslVersionMin: TLS1.2

## disable anonymous bind
ldapmodify -x -D "cn=Directory Manager" -y rootcred.txt << EOF
dn: cn=config
changetype: modify
replace: nsslapd-allow-anonymous-access
nsslapd-allow-anonymous-access: rootdse
EOF
systemctl restart dirsrv.target
ldapsearch -x -b "cn=config" -s base -LLL -D "cn=Directory Manager" -y rootcred.txt | grep nsslapd-allow-anonymous-access

## change passwordStorageScheme for GCDS password sync
# set cn=config
# passwordStorageScheme https://www.redhat.com/archives/freeipa-users/2010-March/msg00043.html
ldapmodify -x -D "cn=Directory Manager" -y rootcred.txt  << EOF
dn: cn=config
changetype: modify
replace: passwordStorageScheme
passwordStorageScheme: SHA
EOF
ldapsearch -x -b "cn=config" -s base -LLL -D "cn=Directory Manager" -y rootcred.txt | grep passwordStorageScheme

## Enabling password reset without prompting for a password change at the next login
# passSyncManagersDNs = who can reset passwords
# The attribute is multi-valued
ldapmodify -x -D "cn=Directory Manager" -y rootcred.txt  << EOF
dn: cn=ipa_pwd_extop,cn=plugins,cn=config
changetype: modify
add: passSyncManagersDNs
passSyncManagersDNs: uid=admin,cn=users,cn=accounts,$root_dn
passSyncManagersDNs: uid=ldap-passwd-reset,cn=users,cn=accounts,$root_dn
passSyncManagersDNs: uid=serviceadmin,cn=users,cn=accounts,$root_dn
EOF
ldapsearch -x -b "cn=ipa_pwd_extop,cn=plugins,cn=config"  -LLL -D "cn=Directory Manager" -y rootcred.txt

# enable last successfull login
kinit admin
ipa config-mod --ipaconfigstring='AllowNThash'


# Edit multi records
# ldapmodify -x -D "cn=Directory Manager" -y rootcred.txt  << EOF
# dn: cn=ipa_pwd_extop,cn=plugins,cn=config
# changetype: modify
# add: passSyncManagersDNs
# passSyncManagersDNs: uid=ldap-passwd-reset,cn=users,cn=accounts,$root_dn
# EOF

# ldapmodify -x -D "cn=Directory Manager" -y rootcred.txt  << EOF
# dn: cn=ipa_pwd_extop,cn=plugins,cn=config
# changetype: modify
# delete: passSyncManagersDNs
# passSyncManagersDNs: uid=bind-passwordreset,cn=users,cn=accounts,$root_dn
# EOF
