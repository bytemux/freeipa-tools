[docs](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/linux_domain_identity_authentication_and_policy_guide/user-authentication#changing-pwds)

# Install
```bash
yum install -y freeipa-server ipa-server-dns pwgen;
ipa-server-install

# Kerberos, HTTP, HTTPS, DNS, NTP, LDAP  (Secured with StartTLS/GSSAPI), LDAPS
firewall-cmd --add-service=freeipa-ldap --permanent; firewall-cmd --add-service=freeipa-ldaps --permanent; firewall-cmd --reload; firewall-cmd --list-all
firewall-cmd --add-service=dns --permanent; firewall-cmd --reload; firewall-cmd --list-all

# Replication whitelist
firewall-cmd --permanent --zone=public --remove-rich-rule='rule family="ipv4" source address="1.1.1.1/32" port protocol="tcp" port="389" accept'
firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" source address="1.1.1.2/32" port protocol="tcp" port="389" accept'
firewall-cmd --reload; firewall-cmd --list-all

```

# Config !! REPEAT ON EACH REPLICA !!
```bash
touch /root/rootcred.txt; chmod 600 /root/rootcred.txt; nano /root/rootcred.txt; truncate -s -1 /root/rootcred.txt;
./ipa-node-prepare.sh

```

# Replica over LDAP (Secured with StartTLS/GSSAPI)
[source](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/linux_domain_identity_authentication_and_policy_guide/install-replica)

```bash
# install if not an IDM client
domain="int.domainname.com"
replica_ip="1.1.1.1"

## on ipa-01
ipa host-del ipa-02.$domain; ipa host-add --force --ip-address=$replica_ip ipa-02.$domain --random; ipa hostgroup-add-member ipaservers --hosts ipa-02.$domain

## on replica
ipa-replica-install --server ipa-01.$domain --domain $domain --setup-ca --setup-dns --forwarder=8.8.8.8 --password 'INSERT_PASSWORD' --skip-conncheck

# Remove replica
ipa server-del ipa-02.int.domainname.com # on remaining server
ipa-server-install --uninstall      # on server chosen for removal
# Check if all NS /DNS records deleted
```

# Change server IP (2 replicas required)
1. have fresh backups/snapshots
2. ipactl stop
3. nano /etc/hosts & nmcli  = change ip
4. powerdown
5. change NS ip (int-ns1 A record), change ipa-01 ip in ipa-02 dns web gui


# Replica HEALTH
```bash
# check health
ipa topologysegment-find domain      # topology
ipa topologysuffix-verify domain     # recomendations
ipa-replica-manage list-ruv          # replicas from which updates are awaited
ipa-replica-manage list              # replicas
ipa-replica-manage force-sync --from server1.example.com

```

# DNS delegation example
```bash
int.domainname.com.    300    IN    NS    int-ns2.domainname.com.
int.domainname.com.    300    IN    NS    int-ns1.domainname.com.
int-ns1.domainname.com.        IN    A    1.1.1.1
int-ns2.domainname.com.        IN    A    1.1.1.2

```

# FYI: to enable selinux after install...
[source](https://bugzilla.redhat.com/show_bug.cgi?id=1436040)

## recommended
ipa-server-upgrade

## manual
```bash
setsebool -P httpd_can_network_connect true;
setsebool -P httpd_manage_ipa true;
setsebool -P httpd_run_ipa true;
setsebool -P httpd_dbus_sssd true;
restorecon -Rv /

# setsebool -P samba_enable_home_dirs true;
# setsebool -P reshare_nfs_with_samba true;
# setsebool -P samba_portmapper true;         # ad trust
```
