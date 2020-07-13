#!/bin/bash
# Usage: ./script.sh list list.csv
# Check progress in progress.log
list_name="${2:-users.csv}"
echo "" > progress.log

function user_list() {
o_total=$(cat $list_name | wc -l)
o_count=0; o_fails=0
OLDIFS=$IFS
IFS=";"
while read name surname mail group1 group2
do
  o_count=$((o_count+1))
  echo -e "Progress: $o_count/$o_total" >> progress.log
  # LIST
  login=$(echo $mail | sed 's/@.*//')
  echo "ipa user-add $login --first $name --last $surname --email $mail --shell=/bin/bash"
  echo "ipa group-add-member $group1 --users=$login"
  echo "ipa group-add-member $group2 --users=$login"
  #
  if [ $? -eq 1 ]; then o_fails=$((o_fails+1)); fi
done < $list_name
echo "Total operations: $o_count"
echo "Success operations: $(($o_count-$o_fails))"
echo "Failed operations: $o_fails"
IFS=$OLDIFS
}

function user_add() {
o_total=$(cat $list_name | wc -l)
o_count=0; o_fails=0
OLDIFS=$IFS
IFS=";"
while read name surname mail group1 group2
do
  o_count=$((o_count+1))
  echo -e "Progress: $o_count/$o_total" >> progress.log
  # ADD
  login=$(echo $mail | sed 's/@.*//')
  password=$(pwgen -1 --capitalize --numerals --secure --ambiguous 12)
  ipa user-add $login --first $name --last $surname --email $mail --shell=/bin/bash
ipa passwd $login <<EOF
$password
$password
EOF
  ipa group-add-member $group1 --users=$login
  ipa group-add-member $group2 --users=$login
  echo "${login};${password}" >> generated_users.csv
  #
  if [ $? -eq 1 ]; then o_fails=$((o_fails+1)); fi
done < $list_name
echo "Total operations: $o_count"
echo "Success operations: $(($o_count-$o_fails))"
echo "Failed operations: $o_fails"
IFS=$OLDIFS
}

function user_del() {
o_total=$(cat $list_name | wc -l)
o_count=0; o_fails=0
OLDIFS=$IFS
IFS=";"
while read name surname mail group
do
  o_count=$((o_count+1))
  echo -e "Progress: $o_count/$o_total" >> progress.log
  # ADD
  login=$(echo $mail | sed 's/@.*//')
  ipa user-del $login
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
  user_list
  shift
  ;;
  add)
  echo "" > generated_users.csv     # CLEAN
  user_add
  shift
  ;;
  del)
  user_del
  shift
  ;;
  *)
  echo "${1} is not a valid flag, try running: ${0} --help"
  exit 1
  ;;
esac
shift
done
