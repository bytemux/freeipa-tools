#!/bin/bash
job_name="ipa-01.int.domainname.com"
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
log_file=$script_dir/$job_name.log

echo -en "Started at $(date +"%Y-%m-%d_%H:%M:%S")\n" &> $log_file

# local backup
#ipa-backup --gpg --gpg-keyring=/root/backup
ipa-backup --data --online --gpg --gpg-keyring=/root/backup

#--- Cleanup vars
clean_dir="/var/lib/ipa/backup/"
keep_days="90"         # Oldest to keep
keep_backups="14"       # Minimum to keep

#--- Cleanup DIRECTORIES v2
if [ ! -z $clean_dir ] && [ $clean_dir != "/" ]
then
  backup_count=$(find $clean_dir/* -name "$job_name*" -type d | wc -l)
  if [ "$backup_count" -gt $keep_backups ]
  then
    echo -en "\n>> CLEANUP: $job_name AT $(date +"%Y-%m-%d_%H:%M:%S")\n $clean_dir\n" >> ${log_file}
    echo $(find $clean_dir/* -name "$job_name*" -mtime +$keep_days -type d) >> ${log_file}
    find $clean_dir/* -name "$job_name*" -mtime +$keep_days -type d -exec rm -rf {} +;
  fi
fi

# copy to remote-accessible dir
mkdir -p /home/backup/$job_name;
rsync -ax --delete-after $clean_dir /home/backup/$job_name
chown -R backup:backup /home/backup/$job_name

# Install script
# touch /home/backup/local_backup.sh; chmod ug+x /home/backup/local_backup.sh
# cp /etc/crontab{,.bak}; echo "30 1 * * * root /home/backup/local_backup.sh" >> /etc/crontab
