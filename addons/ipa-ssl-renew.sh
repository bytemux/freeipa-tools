#/bin/bash
host="$(hostname)"

# pause server & renew cert
# import web server certs & restart ipa only if renewal occurs
certbot renew \
--pre-hook "systemctl stop httpd.service" \
--post-hook "systemctl start httpd.service" \
--deploy-hook "ipa-server-certinstall --pin="" --dirman-password="$(cat /root/rootcred.txt)" --http /etc/letsencrypt/live/$host/privkey.pem /etc/letsencrypt/live/$host/cert.pem; ipactl restart"

# Install script
# touch /root/ipa-ssl-renew.sh; chmod ug+x /root/ipa-ssl-renew.sh;
# cp /etc/crontab{,.bak}; echo "25 0 5 * * root /root/ipa-ssl-renew.sh" >> /etc/crontab

# Get cert first time
# yum install -y certbot
# certbot certonly --standalone -d "$host" \
# --pre-hook "systemctl stop httpd.service" \
# --post-hook "systemctl start httpd.service" \
# --deploy-hook "ipa-server-certinstall --pin="" --dirman-password="$(cat /root/rootcred.txt)" --http /etc/letsencrypt/live/$host/privkey.pem /etc/letsencrypt/live/$host/cert.pem; ipactl restart"
