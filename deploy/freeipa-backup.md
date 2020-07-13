[drp info](https://access.redhat.com/solutions/626303)

## prepare
```bash
# create gpg key
cat >keygen <<EOF
%echo Generating a standard key
Key-Type: RSA
Key-Length:2048
Name-Real: IPA Backup
Name-Comment: IPA Backup
Name-Email: root@example.com
Expire-Date: 0
%pubring /root/backup.pub
%secring /root/backup.sec
%commit
%echo done
EOF

yum install -y haveged;
# generate pgp
systemctl start haveged; gpg --batch --gen-key keygen; systemctl stop haveged;
# add to keyring
gpg --no-default-keyring --secret-keyring /root/backup.sec \
--keyring /root/backup.pub --list-secret-keys

```

## ipa-backup
```bash
# online data only ~06s
ipa-backup --data --online --gpg --gpg-keyring=/root/backup
# offline full ~1m30s
ipa-backup --gpg --gpg-keyring=/root/backup

```

## ipa-restore
```bash
ll /var/lib/ipa/backup/
# online data
ipa-restore --data --online --gpg-keyring=/root/backup /var/lib/ipa/backup/ipa-data-
ipa-restore --gpg-keyring=/root/backup /var/lib/ipa/backup/ipa-full-

# NOTE: clear the SSSD cache after a restore
systemctl stop sssd; find /var/lib/sss/ ! -type d | xargs rm -f; systemctl start sssd

```
