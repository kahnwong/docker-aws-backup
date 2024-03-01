#!/bin/sh

## VARS
#MODE= # `ARCHIVE`
#SERVICE_NAME=
#BACKUP_PATH=

# set filename
current_date=$(date +%Y-%m-%d)
backup_prefix="s3://backup/$current_date"
filename="$SERVICE_NAME-$current_date.tar.gz"

# backup
if [ "$MODE" = "ARCHIVE" ]; then
	tar -czf "$filename" "$BACKUP_PATH"
else
	echo "$MODE is not  supported"
fi

# upload
aws s3 cp --endpoint-url "$S3_ENDPOINT" "$filename" "$backup_prefix/$filename"
curl -d "Successfully backup $SERVICE_NAME" https://ntfy.karnwong.me/nuc-backup
