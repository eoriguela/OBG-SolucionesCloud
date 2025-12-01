#!/bin/bash

DATE=$(date +%F_%H-%M)
FILE="/opt/db-backups/db-${DATE}.sql"

mysqldump -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" > $FILE
aws s3 cp $FILE s3://$S3_BUCKET/