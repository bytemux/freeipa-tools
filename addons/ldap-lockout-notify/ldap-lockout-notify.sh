#!/bin/bash
ldap_base="cn=users,cn=accounts,dc=int,dc=domainname,dc=com"
max_failures=10
slack_hook="https://hooks.slack.com/services/INSERT_PASSWORD"
slack_channel="ldaplockouts"

# auth in kerberos
kinit -V -kt /opt/ldap-lockout-notify/ldap-lockout-notify.keytab ldap-lockout-notify
# Debug
# klist

auth_result=$?
if [ "$auth_result" -ne "0" ] && [ $auth_result -ne "32" ]
then
    echo "$(date +"%Y-%m-%d_%H:%M:%S") - LDAP login failure, check keytab. Stopping script"
    exit
fi

# first run only
[[ -f /tmp/was_locked ]] || touch /tmp/was_locked

# Clear last result
echo "" > /tmp/new_locked

# Get user list
ldapsearch -b "$ldap_base" "(krbLoginFailedCount=$max_failures)" | grep "uid:" | sed -e "s/^uid: //" > /tmp/now_locked

# Substract newly locked users
## print everything in file2 that is not in file1 i.e. file2 - file1
grep -vxFf /tmp/was_locked /tmp/now_locked > /tmp/new_locked

# Save /tmp/was_locked for the next run
cat /tmp/now_locked > /tmp/was_locked

# Send report if there is newly locked users
if [ $(cat /tmp/new_locked | wc -l) -gt 0 ]
then
    echo "$(date +"%Y-%m-%d_%H:%M:%S") - $(cat /tmp/new_locked | wc -l) newly locked users found. Total locked users: $(cat /tmp/now_locked | wc -l). Search condition: krbLoginFailedCount=$max_failures"
    # Send report
    msg_header="[$(hostname)] Account lockout report at $(date +"%Y-%m-%d_%H:%M:%S")"
    msg_body="*Lockout state discovered on following users:*
$(cat /tmp/new_locked)
*Wrong password was entered $max_failures times, which may indicate brute-force attempt.*"
    curl -X POST --data-urlencode 'payload={"channel": "'"$slack_channel"'", "username": "announce", "text": "'"$msg_header"'\n'"$msg_body"'", "icon_emoji": ":ms:", "mrkdwn": true }' $slack_hook
# Log if there is no newly locked user
else
    echo "$(date +"%Y-%m-%d_%H:%M:%S") - no newly locked users found. Total locked users: $(cat /tmp/now_locked | wc -l). Search condition: krbLoginFailedCount=$max_failures"
fi
