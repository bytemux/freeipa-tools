# LDAP SETTINGS
[source](https://www.jfrog.com/confluence/display/RTF/Managing+Security+with+LDAP#ManagingSecuritywithLDAP)

ldap url        ldaps://ipa-01.int.domainname.com:636/dc=int,dc=domainname,dc=com
search filter   (&(uid={0})(memberOf=cn=it-department,cn=groups,cn=accounts,dc=int,dc=domainname,dc=com))
search base     cn=users,cn=accounts
manager dn      uid=binduser,cn=users,cn=accounts,dc=int,dc=domainname,dc=com

![text](artifactory-ldap.jpg "Logo Title Text 1")


# Add ldap-ca.crt to artifactory docker installation
```bash
# place .crt file
mkdir /home/domainname/artifactory_extra_certs; nano /home/domainname/artifactory_extra_certs/ldap-ca.crt; chown -R 1030:1030 /home/domainname/artifactory_extra_certs

# add mount directory
volumes:
 - /home/domainname/artifactory_extra_certs:/artifactory_extra_certs

# restart container
docker restart artifactory
#artifactory    | 2019-12-04 12:40:49  [448 entrypoint-artifactory.sh] Adding extra certificates to Java keystore if exist
#artifactory    | 2019-12-04 12:40:49  [463 entrypoint-artifactory.sh] Adding /artifactory_extra_certs/ldap-ca.crt to Java cacerts
#artifactory    | Certificate was added to keystore
```

# Preventing Authentication Fallback to the Local Artifactory Realm
Disable Internal Password checkbox in the Edit User dialog is set.

# Avoiding Clear Text Passwords
General Security Configuration > Password Encryption Policy > Required

