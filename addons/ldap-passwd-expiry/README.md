[Code source](https://github.com/meroupatate/ldap-password-expiration-notifier)
Modified version supports notifications via Slack and Email

## Prerequisites
- a LDAP server with configured password expiration policy
- a working local mail relay server (e.g. postfix)
- python3 (version > 3.6)
- python3-pip

## INSTALL
```bash
# DEBIAN
sudo apt-get install libsasl2-dev python-dev libldap2-dev libssl-dev

# CENTOS
yum install python3 python3-dev python3-devel openldap-devel python-devel
mkdir -p /opt/ldap-password-expiry
cd ldap-password-expiry/

virtualenv -p python3 ./virtualenv
. ./virtualenv/bin/activate
pip install --upgrade pip; pip install -r requirements.txt

cp /etc/crontab{,.bak}; echo "00 10 * * * root /opt/ldap-passwd-expiry/virtualenv/bin/python /opt/ldap-passwd-expiry/notifier.py" >> /etc/crontab

# or
# nano /usr/lib/systemd/system/ldap-passwd-expiry.service
# systemctl daemon-reload; systemctl enable ldap-passwd-expiry

```

