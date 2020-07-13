# LDAP settings
ldap_url = 'ldap://127.0.0.1:9389'
ldap_user = 'uid=ldap-password-expiry,cn=users,cn=accounts,dc=int,dc=domainname,dc=com'
ldap_user_search_base_dn = "cn=users,cn=accounts,dc=int,dc=domainname,dc=com"
## SECRET
ldap_password = 'INSERT_PASSWORD'

# Email settings
mail_enabled = True
mail_default = 'support@domainname.com'
mail_subject = "[int.domainname.com] Your password is expiring! Days to expire: {0}"
mail_template = "Hi, *{0}*. Your password is expiring! Days to expire: *{1}*\To change password go to https://ipa-01.int.domainname.com/ and click on your login in upper right corner. Leave OTP field empty.\nMore info: URL\n"

smtp_from = None #With None its copy value from smtp_user
smtp_user = "support@domainname.com"
smtp_server_addr = "smtp.mail.com"
smtp_server_port = 587
smtp_server_tls = True
## SECRET
smtp_pass = "INSERT_PASSWORD"

# Slack settings
slack_enabled = True
slack_default = '#slack-test'
slack_template = "*[int.domainname.com]* Hi, *{0}*. Your password is expiring! Days to expire: *{1}*\nTo change password go to https://ipa-01.int.domainname.com/ and click on your login in upper right corner. Leave OTP field empty.\nMore info: URL\n"
# Set the webhook_url to the one provided by Slack when you create the webhook at https://my.slack.com/services/new/incoming-webhook/
slack_username = "announce"
slack_icon_emoji = ":domainname:"
## SECRET
slack_bot_token= "INSERT_PASSWORD"

# Notification is sent 10,5,3,2,1 days before password expiration
pwdWarnDays = [10, 5, 3, 2, 1]
