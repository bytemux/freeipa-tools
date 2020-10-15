# freeipa-tools
Helpful addons and scripts for managing FreeIPA 4.6.x

Everything is tested with Freeipa 4.6.5, Centos 7

## Repo content
- **addons**. Essential scripts to improve user experience
  - **gcds**. Sync directory with gSuite. This is useful to further synchronization with cloud services like Slack, Atlassian, etc.
  - **ldap-lockout-notify**. Notify in Slack about user account lockouts. Useful for monitoring brute-force attempts.
  - **ldap-passwd-expiry**. Notify in Slack and Email about user account password expiry. Forked from https://github.com/meroupatate/ldap-password-expiration-notifier
  - **ldap-passwd-reset**. Self service password reset page. To reset password user need to receive token via Slack or Email. Forked from https://github.com/larrabee/freeipa-password-reset. (I contributed the slack nofitifaction functionality there)
  - **ipa-ssl-renew.sh**. Setup Let's encrypt with FreeIPA and add certs renewal to cron
  - **local_backup.sh**. Backup FreeIPA master server to local storage
- **deploy**. Manual deploy folder for getting familiar with FreeIPA, for full production deployments i suggest use of https://github.com/freeipa/ansible-freeipa
  - **ipa-node-prepare.sh**. Set some settings that are not replicated between masters. Mainly hardens security.
- **integrations**. Example configs for integrating clients with LDAP server. Most notable include:
  - centos (sssd ssh + sudo via ipaclient)
  - openshift
  - gitlab (this is the most generic example - most of stuff applies to every other OSS if they follow conventional design)
  - proxmox
  - seafile
- **import**. Generate users and groups from csv. Send user credentials via Slack private messages

## What this repo currently lacks, but you might want for your deployment
- Tested HAproxy/Nginx configs to balance incoming ldap traffic
- Logging and Audit conveniences. https://www.freeipa.org/page/Centralized_Logging

## Useful docs
- https://www.redhat.com/archives/freeipa-users/2016-October/msg00325.html
- https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/pdf/linux_domain_identity_authentication_and_policy_guide/Red_Hat_Enterprise_Linux-7-Linux_Domain_Identity_Authentication_and_Policy_Guide-en-US.pdf
- https://www.redhat.com/archives/freeipa-users/2014-April/msg00243.html
