#!/bin/bash

yum update -y
yum install -y mysql awscli

# Descargar dump.sql desde S3 usando IAM Role
aws s3 cp s3://${s3_bucket}/dump.sql /tmp/dump.sql

# Esperar a que el RDS esté accesible
for i in {1..30}; do
    mysql -h ${db_endpoint} -u ${db_username} -p${db_password} -e "SHOW DATABASES;" && break
    echo "Esperando RDS..."
    sleep 10
done

# Importar dump
mysql -h ${db_endpoint} -u ${db_username} -p${db_password} ${db_name} < /tmp/dump.sql

echo "Importación completada"
