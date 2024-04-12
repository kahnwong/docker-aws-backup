#!/bin/bash

## VARS
#MODE= # `ARCHIVE`, `DB_POSTGRES`
#SERVICE_NAME=
#BACKUP_PATH=

#BACKUP_PATH_EXCLUDE= # optional

#POSTGRES_USERNAME=
#POSTGRES_PASSWORD=
#POSTGRES_HOSTNAME=

#S3_ENDPOINT= # optional
#NTFY_TOPIC

# set filename
current_date=$(date +%Y-%m-%d)
backup_prefix="s3://backup/$current_date"

# backup
if [ "$MODE" = "ARCHIVE" ]; then
	filename="$SERVICE_NAME-$current_date.tar.gz"

	# ref: https://stackoverflow.com/a/42985721
	tar_args=(
		-czf "$filename" "$BACKUP_PATH"
	)
	if [ -v BACKUP_PATH_EXCLUDE ]; then
		tar_args+=(--exclude "$BACKUP_PATH_EXCLUDE")
	fi

	tar "${tar_args[@]}"

elif [ "$MODE" = "DB_POSTGRES" ]; then
	filename="$SERVICE_NAME-sqldump-$current_date.bin"
	PGPASSWORD="$POSTGRES_PASSWORD" pg_dump -Fc -c -U "$POSTGRES_USERNAME" --host "$POSTGRES_HOSTNAME" >"$filename"

else
	echo "$MODE is not supported"
fi

# upload
aws_args=()
if [ -v S3_ENDPOINT ]; then
	aws_args+=(--endpoint-url "$S3_ENDPOINT")
fi

aws s3 cp "${aws_args[@]}" "$filename" "$backup_prefix/$filename"
curl -d "Successfully backup $SERVICE_NAME" "$NTFY_TOPIC"
