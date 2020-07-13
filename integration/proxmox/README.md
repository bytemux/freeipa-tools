# proxmox + ldap
1. Add realm
- Setup via gui > datacenter
- Add bind credentials via shell
```bash
# addinsert bind_dn
nano /etc/pve/domains.cfg

# INSERT_PASSWORD
mkdir /etc/pve/priv/ldap/; nano /etc/pve/priv/ldap/int.domainname.com.pw; truncate -s -1 /etc/pve/priv/ldap/ldap.pw
```
2. Add new group named LDAP_admin
3. Add permission for path "/", "LDAP_admin", role "Administrator"
4. Create user login = uid in FreeIPA
5. At login select LDAP

