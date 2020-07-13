#!/bin/bash
# Usage: ./script.sh list list.csv
# Check progress in progress.log
list_name="${2:-groups.csv}"
echo "" > progress.log

function group_list() {
o_total=$(cat $list_name | wc -l)
o_count=0; o_fails=0
OLDIFS=$IFS
IFS=";"
while read group mail memberof_it_department
do
  o_count=$((o_count+1))
  echo -e "Progress: $o_count/$o_total" >> progress.log
  # LIST
  echo "ipa group-add $group --desc '$mail'"
  if [ $memberof_it_department == "yes" ]; then echo "ipa group-add-member it-department --groups=$group"; fi
  #
  if [ $? -eq 1 ]; then o_fails=$((o_fails+1)); fi
done < $list_name
echo "Total operations: $o_count"
echo "Success operations: $(($o_count-$o_fails))"
echo "Failed operations: $o_fails"
IFS=$OLDIFS
}

function group_add() {
o_total=$(cat $list_name | wc -l)
o_count=0; o_fails=0
OLDIFS=$IFS
IFS=";"
while read group mail memberof_it_department
do
  o_count=$((o_count+1))
  echo -e "Progress: $o_count/$o_total" >> progress.log
  # ADD
  ipa group-add $group --desc "$mail"
  if [ $memberof_it_department == "yes" ]; then ipa group-add-member it-department --groups=$group; fi
  #
  if [ $? -eq 1 ]; then o_fails=$((o_fails+1)); fi
done < $list_name
echo "Total operations: $o_count"
echo "Success operations: $(($o_count-$o_fails))"
echo "Failed operations: $o_fails"
IFS=$OLDIFS
}

function group_del() {
o_total=$(cat $list_name | wc -l)
o_count=0; o_fails=0
OLDIFS=$IFS
IFS=";"
while read group mail memberof_it_department
do
  o_count=$((o_count+1))
  echo -e "Progress: $o_count/$o_total" >> progress.log
  # DEL
  ipa group-del $group
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
  group_list
  shift
  ;;
  add)
  group_add
  shift
  ;;
  del)
  group_del
  shift
  ;;
  *)
  echo "${1} is not a valid flag, try running: ${0} --help"
  exit 1
  ;;
esac
shift
done

