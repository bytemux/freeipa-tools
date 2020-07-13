#!/usr/bin/python3

import ldap
import smtplib
from email.mime.text import MIMEText
from datetime import datetime
from config import *

import json
import requests
import slack

def filter_emails(emails):
    if len(emails) == 0:
        print(f'User does not have email addresses')
        pass
    filtered_emails = []
    for email in emails:
        # try:
        #     validate_email(email)
        # except ValidationError:
        #     pass
        # else:
        filtered_emails.append(email)
    if len(filtered_emails) == 0:
        print(f'User does not have valid email addresses')
        pass
    return filtered_emails

def send_mail(user, pwdUntilExpirationTime):
    uid = user['uid'][0].decode()
    recipient = user.get('mail',[])
    recipient = recipient[0].decode('utf-8')

    if len(recipient) == 0:
        print(f'User {uid}: Email not found')
        return

    try:
        msg = MIMEText(mail_template.format(uid,pwdUntilExpirationTime.days))
        msg['Subject'] = mail_subject.format(pwdUntilExpirationTime.days)
        if smtp_from is not None:
            msg['From'] = smtp_from
        else:
            msg['From'] = smtp_user
        msg['To'] = recipient
        s = smtplib.SMTP("{0}:{1}".format(smtp_server_addr, smtp_server_port))
        if smtp_server_tls:
            s.ehlo()
            s.starttls(tuple())
            s.ehlo()
        if (smtp_user is not None) and (smtp_pass is not None):
            s.login(smtp_user, smtp_pass)
        s.sendmail(msg['From'], recipient, msg.as_string())
        s.quit()
    except:
        print(f'User {uid}: Cannot send Email')
        pass
    return

def send_slack_bot_personal(user, pwdUntilExpirationTime, slack_bot_token):
    uid = user['uid'][0].decode()

    client = slack.WebClient(slack_bot_token)
    response = client.chat_postMessage(
        channel='@%s' % uid,
        text=slack_template.format(uid, pwdUntilExpirationTime.days),
        mrkdwn='true',
        username=slack_username,
        icon_emoji=slack_icon_emoji
        )
    if response['ok']:
        return
    else:
        print(f"Send to slack returned an error")
        pass

def send_slack_bot_default(user, pwdUntilExpirationTime, slack_bot_token, slack_default):
    uid = user['uid'][0].decode()

    client = slack.WebClient(slack_bot_token)
    response = client.chat_postMessage(
        channel=slack_default,
        text="User is unreacheable, sending message to default channel\n" + slack_template.format(uid, pwdUntilExpirationTime.days),
        mrkdwn='true',
        username=slack_username,
        icon_emoji=slack_icon_emoji
        )
    if response['ok']:
        return
    else:
        print(f"Send to slack returned an error")

def get_slack_users():
    client = slack.WebClient(slack_bot_token)
    request = client.api_call("users.list")
    slack_users = []
    if request['ok']:
        for item in request['members']:
            slack_users.append(item['name'])
    else:
        print(f"Can't list slack users")
    return (slack_users)

def get_user_details():
    l = ldap.initialize(ldap_url)
    l.set_option(ldap.OPT_X_TLS_REQUIRE_CERT, ldap.OPT_X_TLS_NEVER)
    l.simple_bind_s(ldap_user,ldap_password)
    # Perform LDAP Search
    data = l.search_s(ldap_user_search_base_dn, ldap.SCOPE_SUBTREE, '(uid=*)', ['uid','krbLastPwdChange', 'mail', 'krbPasswordExpiration'])
    return [ d[1] for d in data ]

def check_password_expiry(ldap_users, slack_users):
    for user in ldap_users:
        uid = user['uid'][0].decode()
        user_email = user.get('mail',[])
        todayTime = datetime.now()

        try:
            krbPasswordExpiration = user['krbPasswordExpiration'][0].decode()
        except:
            print(f'User {uid}: krbPasswordExpiration not set. User never had a password?')
            krbPasswordExpiration = '20771011233159Z'
            pass

        pwdExpirationTime = datetime.strptime(krbPasswordExpiration, '%Y%m%d%H%M%SZ')
        # Number of days until next password update
        pwdUntilExpirationTime = pwdExpirationTime - todayTime

        # Password expired, do not notify
        if  pwdExpirationTime < todayTime:
            print(f'User {uid}: password expired for {-pwdUntilExpirationTime.days} days')
            continue

        # Password not expired, send notifications
        print(f'User {uid}: password is valid for {pwdUntilExpirationTime.days} days')

        if (pwdUntilExpirationTime.days in pwdWarnDays):
        #if (uid == "bind-gitlab"): # NOTE: DEBUG ONLY
            # User does not have email or slack. Send support notification.
            if (uid not in slack_users) or (len(user_email) == 0):
                print(f'User {uid}: User does not have slack or email, sending notification to {slack_default}')
                send_slack_bot_default(user, pwdUntilExpirationTime, slack_bot_token, slack_default)
                continue

            # Send personal notification
            print(f'User {uid}: sending notification. Slack: {slack_enabled}, Email: {mail_enabled}')
            if slack_enabled:
                send_slack_bot_personal(user, pwdUntilExpirationTime, slack_bot_token)
            if mail_enabled:
                send_mail(user, pwdUntilExpirationTime)
    return

if __name__ == '__main__':
    ldap_users = get_user_details()
    slack_users = get_slack_users()

    print(f'{datetime.now()} - Starting password expiry check')
    check_password_expiry(ldap_users, slack_users)


