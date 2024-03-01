#!/bin/sh

## VARS
#MODE= # `ARCHIVE`
#SERVICE_NAME=
#BACKUP_PATH=
#BACKUP_PATH_EXCLUDED= # optional

# set filename
current_date=$(date +%Y-%m-%d)
backup_prefix="s3://backup/$current_date"
filename="$SERVICE_NAME-$current_date.tar.gz"

# backup
if [ "$MODE" = "ARCHIVE" ]; then
	if [ -z "${BACKUP_PATH_EXCLUDED+x}" ]; then
		tar -czf "$filename" "$BACKUP_PATH"
	else
		tar --exclude "$BACKUP_PATH_EXCLUDED" -czf "$filename" "$BACKUP_PATH"
	fi
else
	echo "$MODE is not  supported"
fi

# upload
aws s3 cp --endpoint-url "$S3_ENDPOINT" "$filename" "$backup_prefix/$filename"
curl -d "Successfully backup $SERVICE_NAME" https://ntfy.karnwong.me/nuc-backup
