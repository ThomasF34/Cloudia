#!/bin/bash

if [[ -z "${RECIPIENT_ID}" ]]; then
  echo "ERROR: Please provide RECIPIENT_ID env var"
  exit 1
else
  RECIPIENT="${RECIPIENT_ID}"
fi

if [[ -z "${CHECK_URL}" ]]; then
  echo "ERROR: Please provide CHECK_URL if you want to monitor your cron"
fi

echo "Begin BACKUP"
if [[ -z "${CHECK_URL}" ]]; then
  echo "Sending start signal to CHECK URL"
  curl -fsS -m 10 --retry 5 -o /dev/null ${CHECK_URL}/start
fi

DATE=$(date +%Y%m%d%H%M%S)
echo "Create folder $DATE"
FOLDER="/media/Data/BACKUPS/backup_$DATE"
sudo mkdir $FOLDER/


echo "Put nextcloud into maintenance mode"
docker exec -u 33 -it cloudia_cloud_1 php occ maintenance:mode --on

echo "Backup nextcloud"
sudo rsync -Aavx /media/Data/Nextcloud/data/data/Nelands/files $FOLDER/nextcloud_files/

echo "Put nextcloud out of maintenance mode"
docker exec -u 33 -it cloudia_cloud_1 php occ maintenance:mode --off


echo "Create tarball"
sudo tar cvzf $FOLDER.tar.gz $FOLDER
echo "Remove folder"
sudo rm -rf $FOLDER
echo "Encrypt tarball"
sudo gpg -r $RECIPIENT -o /media/Data/BACKUPS/Encrypted/backup_$DATE.pgp -e $FOLDER.tar.gz
echo "Remove tarball"
sudo rm -rf $FOLDER.tar.gz


echo "Sync Encrypted folder with BackBlaze"
rclone copy /media/Data/BACKUPS/Encrypted Backup_B2:cloud-backup-nelands
if [[ -z "${CHECK_URL}" ]]; then
  echo "Sending end signal to CHECK URL"
  curl -fsS -m 10 --retry 5 -o /dev/null ${CHECK_URL}/$?
fi
echo "Backup sent to BackBlaze bucket"
