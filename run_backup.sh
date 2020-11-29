#!/bin/bash

LOG_FILE_PATH=/home/pi/backup.log
rm $LOG_FILE_PATH
log()
{
  LOGS=$@
  echo $(date -u) "Registering logs: $LOGS"
  echo $(date -u) "$LOGS" >> $LOG_FILE_PATH
}

log "Starting backup script"


if [[ -z "${BACKUP_DIRS}" ]]; then
  log "ERROR: Please provide BACKUP_DIRS env var"
  exit 1
else
  BACKUPDIRS="${BACKUP_DIRS}"
fi

if [[ -z "${RECIPIENT_ID}" ]]; then
  log "ERROR: Please provide RECIPIENT_ID env var"
  exit 1
else
  RECIPIENT="${RECIPIENT_ID}"
fi

if [[ -z "${CHECK_URL}" ]]; then
  log "ERROR: Please provide CHECK_URL if you want to monitor your cron"
fi

echo "Begin BACKUP"
if [[ -n "${CHECK_URL}" ]]; then
  log "Sending start signal to CHECK URL"
  curl -fsS -m 10 --retry 5 -o /dev/null ${CHECK_URL}/start
fi

DATE=$(date +%Y%m%d%H%M%S)
log "Create folder $DATE"
FOLDER="/media/Data/BACKUPS/backup_$DATE"
sudo mkdir $FOLDER/

backup()
{
	BACKUP_DIR=$1
	BACKUP_NAME=$2

	log "Put nextcloud into maintenance mode"
	docker exec -u 33 -it cloudia_cloud_1 php occ maintenance:mode --on

	FULL_BACKUP_DIR=$FOLDER/$BACKUP_NAME
	log "Backup $BACKUP_NAME"
	sudo rsync -Aavx $BACKUP_DIR $FULL_BACKUP_DIR

	log "Put nextcloud out of maintenance mode"
	docker exec -u 33 -it cloudia_cloud_1 php occ maintenance:mode --off


	log "Create $FULL_BACKUP_DIR tarball"
	sudo tar cvzf $FULL_BACKUP_DIR.tar.gz $FULL_BACKUP_DIR
	log "Remove $FULL_BACKUP_DIR folder"
	sudo rm -rf $FULL_BACKUP_DIR
	log "Encrypt $FULL_BACKUP_DIR tarball"
	gpg -r $RECIPIENT -o /media/Data/BACKUPS/Encrypted/backup_${BACKUP_NAME}_$DATE.pgp -e $FULL_BACKUP_DIR.tar.gz
	log "Remove $FULL_BACKUP_DIR tarball"
	sudo rm -rf $FULL_BACKUP_DIR.tar.gz
}

cat $BACKUPDIRS | while read -r backup; do
  DIR=$(echo $backup | cut -d ':' -f 1)
  NAME=$(echo $backup | cut -d ':' -f 2)
  log "Backuping dir $DIR with name $NAME"
  backup $DIR $NAME
done

log "Sync Encrypted folder with BackBlaze"
rclone copy /media/Data/BACKUPS/Encrypted Backup_B2:cloud-backup-nelands
UPLOAD_STATE=$?
if [[ $? -eq 0 ]]; then
  log "Upload succesful"
  rm /media/Data/BACKUPS/Encrypted/*
fi

BACKUP_RECENT_COUNT=$(rclone --max-age 5d ls Backup_B2:cloud-backup-nelands | wc -l)
if [ $BACKUP_RECENT_COUNT -gt 3 ]; then
  log "There are $BACKUP_RECENT_COUNT recent backup. Removing 5 days old backup..."
  BACKUP_OLD_COUNT=$(rclone --min-age=5d ls Backup_B2:cloud-backup-nelands | wc -l)
  if [ $BACKUP_OLD_COUNT -gt 0 ]; then
    log "Removing following backup :$(rclone --min-age=5d ls Backup_B2:cloud-backup-nelands)"
    rclone --min-age=5d delete Backup_B2:cloud-backup-nelands
    log "Removed"
  else
    log "No old backup to remove. No deletion"
  fi
else
  log "Not enough recent backup to remove old one"
  if [[ -n "${CHECK_URL}" ]]; then
    log "The backup has not been run for a long time, sending alert"
    curl -fsS -m 10 --retry 5 -o /dev/null ${CHECK_URL}/fail
  fi
fi

if [[ -n "${CHECK_URL}" ]]; then
  log "Sending end signal to CHECK URL"
  curl -fsS -m 10 --retry 5 -o /dev/null ${CHECK_URL}/$UPLOAD_STATE
fi
log "Backup sent to BackBlaze bucket"

# Sending logs
if [[ -n "${CHECK_URL}" ]]; then
  curl -fsS -m 10 --retry 5 --data-raw "$(cat $LOG_FILE_PATH)" ${CHECK_URL}
fi
