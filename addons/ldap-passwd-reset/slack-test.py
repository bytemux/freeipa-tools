#!/bin/python
# -*- coding: utf-8 -*-

import json
import requests

class SlackValidateFailed(Exception):
    pass
class SlackSendFailed(Exception):
    pass

class Slack():
    def __init__(self, options):
        self.msg_template = options['msg_template']
        self.slack_hook = options['slack_hook']
        self.slack_username = options['slack_username']
        self.slack_icon_emoji = options['slack_icon_emoji']

    def __filter_login(self, uid):
        if len(uid) == 0:
            raise SlackValidateFailed("User login not found")
        return uid

    def send_token(self, user, token):
        recipient = user['result']['uid'][0]
        recipient = self.__filter_login(recipient)
        msg = self.msg_template.format(token)
        self.slack_payload = {'channel': '@%s' % recipient, 'username': self.slack_username, 'text': msg, 'icon_emoji': self.slack_icon_emoji, 'mrkdwn': 'true' }

        response = requests.post(
            self.slack_hook, data=json.dumps(self.slack_payload),
            headers={'Content-Type': 'application/json'}
        )
        print (response.status_code)

        if response.status_code != 200:
            raise SlackSendFailed(
                'Request to slack returned an error %s, the response is:\n%s'
                % (response.status_code, response.text)
            )

options = {
            # In template {0} will replaced with token
            "msg_template": "*[int.domainname.com]* Ваш код для сброса пароля LDAP: {0} \nНикому не сообщайте его.",
            # Set the webhook_url to the one provided by Slack when you create the webhook at https://my.slack.com/services/new/incoming-webhook/
            "slack_hook" : "https://hooks.slack.com/services/INSERT_PASSWORD",
            "slack_username" : "announce",
            "slack_icon_emoji" : ":domainname:"
        }
user = {'result': {'uid':['username']}}

print ('line 1 to stdout  ')

sl = Slack(options)

sl.send_token(user, "testoken")



