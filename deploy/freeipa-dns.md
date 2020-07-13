# ipa dns (named, bind, named-pkcs11)
## force update dns
rndc reload

## force update after topology change
ipa dns-update-system-records

## mod records
ipa dnsrecord-add int.domainname.com bar --a-rec 9.9.9.9
ipa dnsrecord-del int.domainname.com bar

## config
cat /etc/named.conf
https://github.com/freeipa/bind-dyndb-ldap

named-checkconf -p

rndc dumpdb -zones; cat /var/named/data/cache_dump.db

journalctl -fu named-pkcs11
