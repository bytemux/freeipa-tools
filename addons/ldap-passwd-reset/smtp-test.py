#!/bin/python

import smtplib
from email.mime.text import MIMEText

class Email():
    def __init__(self, options):
        self.msg_template = options['msg_template']
        self.msg_subject = options['msg_subject']
        self.smtp_user = options['smtp_user']
        self.smtp_pass = options['smtp_pass']
        self.smtp_server_addr = options['smtp_server_addr']
        self.smtp_server_port = options['smtp_server_port']
        self.smtp_server_tls = options['smtp_server_tls']
        if ('smtp_from' in options) and (options['smtp_from'] is not None):
            self.smtp_from = options['smtp_from']
        else:
            self.smtp_from = self.smtp_user

    def send_token(self, user, token):
        recipients = user['result']['mail']

        msg = MIMEText(self.msg_template.format(token))
        msg['Subject'] = self.msg_subject
        msg['From'] = self.smtp_from
        msg['To'] = ", ".join(recipients)
        s = smtplib.SMTP("{0}:{1}".format(self.smtp_server_addr, self.smtp_server_port))
        if self.smtp_server_tls:
            s.ehlo()
            s.starttls(tuple())
            s.ehlo()
        if (self.smtp_user is not None) and (self.smtp_pass is not None):
            s.login(self.smtp_user, self.smtp_pass)
        s.sendmail(msg['From'], recipients, msg.as_string())
        s.quit()

options = {
            # In template {0} will replaced with token
            "msg_template": "Your reset password token: {0} \nDo not tell anyone this code.",
            "msg_subject": "Your LDAP password reset code",
            "smtp_from": "support@domainname.com", #With None its copy value from smtp_user
            "smtp_user": "support@domainname.com",
            "smtp_pass": "INSERT_PASSWORD",
            "smtp_server_addr": "smtp.mail.com",
            "smtp_server_port": 587,
            "smtp_server_tls": True,
        }
user = {'result': {'mail':['username@domainname.com',]}}

print ('line 1 to stdout  ')

em = Email(options)

em.send_token(user, "test")
