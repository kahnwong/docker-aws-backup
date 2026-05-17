#!/usr/local/bin/bash

# ----------------- VARS ----------------- #
#MODE= # `ARCHIVE`, `DB_POSTGRES`
#SERVICE_NAME=
#BACKUP_PATH=
#BUCKET_NAME=
#BACKUP_PATH_EXCLUDE= # optional

#POSTGRES_USERNAME=
#POSTGRES_PASSWORD=
#POSTGRES_HOSTNAME=

#S3_ENDPOINT= # optional

# either of this
#NTFY_TOPIC_URL
#DISCORD_WEBHOOK_URL

# set filename
current_date=$(date +%Y-%m-%d)

backup_bucket="${BUCKET_NAME:-backup}"
backup_prefix="s3://$backup_bucket/$current_date"

# backup
if [ "$MODE" = "ARCHIVE" ]; then
	filename="$SERVICE_NAME-$current_date.tar.gz"

	# ref: https://stackoverflow.com/a/42985721
	tar_args=()
	if [ -v BACKUP_PATH_EXCLUDE ]; then
		tar_args+=(--exclude "$BACKUP_PATH_EXCLUDE")
	fi
	tar_args+=(
		-czf "$filename" "$BACKUP_PATH"
	)

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

# notify
notify_message="Successfully backup $SERVICE_NAME"
if [ -v NTFY_TOPIC_URL ]; then
	curl -d "$notify_message" "$NTFY_TOPIC_URL"
elif [ -v DISCORD_WEBHOOK_URL ]; then
	curl -i \
		-H "Accept: application/json" \
		-H "Content-Type:application/json" \
		-X POST --data "{\"content\": \"$notify_message\"}" \
		"$DISCORD_WEBHOOK_URL"
else
	echo "Cannot send a notification since no notification backend has been configured."
fi
