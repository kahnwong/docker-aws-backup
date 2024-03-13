#!/bin/sh

## VARS
#MODE= # `ARCHIVE`, `DB_POSTGRES`
#SERVICE_NAME=
#BACKUP_PATH=

#BACKUP_PATH_EXCLUDED= # optional

#POSTGRES_USERNAME=
#POSTGRES_PASSWORD=
#POSTGRES_HOSTNAME=

# set filename
current_date=$(date +%Y-%m-%d)
backup_prefix="s3://backup/$current_date"

# backup
if [ "$MODE" = "ARCHIVE" ]; then
	filename="$SERVICE_NAME-$current_date.tar.gz"

	if [ -z "${BACKUP_PATH_EXCLUDED+x}" ]; then
		tar -czf "$filename" "$BACKUP_PATH"
	else
		tar --exclude "$BACKUP_PATH_EXCLUDED" -czf "$filename" "$BACKUP_PATH"
	fi

elif [ "$MODE" = "DB_POSTGRES" ]; then
	filename="$SERVICE_NAME-sqldump-$current_date.bin"
	PGPASSWORD="$POSTGRES_PASSWORD" pg_dump -Fc -c -U "$POSTGRES_USERNAME" --host "$POSTGRES_HOSTNAME" >"$filename"

else
	echo "$MODE is not supported"
fi

# upload
aws s3 cp --endpoint-url "$S3_ENDPOINT" "$filename" "$backup_prefix/$filename"
curl -d "Successfully backup $SERVICE_NAME" https://ntfy.karnwong.me/nuc-backup
