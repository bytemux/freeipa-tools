
```bash
domain="int.domainname.com"

# ipa cert
docker exec acme.sh --issue -d ipa.$domain -d ipa-01.$domain -d ipa-02.$domain --dns --yes-I-know-dns-manual-mode-enough-go-ahead-please;
sleep 900;
docker exec acme.sh --renew -d ipa.$domain -d ipa-01.$domain -d ipa-02.$domain --dns --yes-I-know-dns-manual-mode-enough-go-ahead-please;

# import lels ca
wget https://letsencrypt.org/certs/isrgrootx1.pem | sudo ipa-cacert-manage install isrgrootx1.pem -n ISRGRootCAX1 -t C,,
wget https://letsencrypt.org/certs/letsencryptauthorityx3.pem | sudo ipa-cacert-manage install letsencryptauthorityx3.pem -n ISRGRootCAX3 -t C,,

kinit admin
ipa-certupdate -v

# import web server certs
ipa-server-certinstall --http ipa.key ipa.crt; systemctl restart httpd.service

# patch windows GSSAPI
sed -i '/^[A-Za-z]*<Location "\/ipa">/ a #fix windows browser basic auth popup\nBrowserMatch Windows gssapi-no-negotiate\n' /etc/httpd/conf.d/ipa.conf; systemctl reload httpd

```



