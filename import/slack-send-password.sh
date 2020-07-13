#!/bin/bash
# Usage: ./script.sh list list.csv
# Check progress in progress.log
list_name="${2:-generated-users.csv}"
SLACK_TOKEN_URL="${3:null}"
echo "" > progress.log

function dm_list() {
o_total=$(cat $list_name | wc -l)
o_count=0; o_fails=0
OLDIFS=$IFS
IFS=";"
while read login password
do
  o_count=$((o_count+1))
  echo -e "Progress: $o_count/$o_total" >> progress.log
  # LIST
  echo -en "\n*Логин:* $login\n*Пароль:* $password"
  #
  if [ $? -eq 1 ]; then o_fails=$((o_fails+1)); fi
done < $list_name
echo "Total operations: $o_count"
echo "Success operations: $(($o_count-$o_fails))"
echo "Failed operations: $o_fails"
IFS=$OLDIFS
}

function dm_send() {
o_total=$(cat $list_name | wc -l)
o_count=0; o_fails=0
OLDIFS=$IFS
IFS=";"
while read login password
do
  o_count=$((o_count+1))
  echo -e "Progress: $o_count/$o_total" >> progress.log
  # SEND
  echo -en "\n${login}: "
  curl -X POST --data-urlencode "payload={'channel': '@$login', 'username': 'announce', 'text': 'Hey $login, here's your account data!\n*login:*$login\n*password:* $password\n. Don't forget to change password to new one, see URL for the instructions' , 'icon_emoji': ':domainname:', 'mrkdwn': true }" $SLACK_TOKEN_URL
  sleep 1
  #
  if [ $? -eq 1 ]; then o_fails=$((o_fails+1)); fi
done < $list_name
echo "Total operations: $o_count"
echo "Success operations: $(($o_count-$o_fails))"
echo "Failed operations: $o_fails"
IFS=$OLDIFS
}

while [[ $# > 0 ]]
do
case "${1}" in
  list)
  dm_list
  shift
  ;;
  send)
  dm_send
  shift
  ;;
  *)
  echo "${1} is not a valid flag, try running: ${0} --help"
  exit 1
  ;;
esac
shift
done
