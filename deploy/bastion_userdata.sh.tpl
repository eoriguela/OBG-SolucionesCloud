#!/bin/bash

yum update -y
yum install -y mysql wget

# Descargar dump.sql desde S3 público
wget https://${s3_bucket}.s3.amazonaws.com/dump.sql -O /tmp/dump.sql

# Esperar a que el RDS esté accesible
for i in {1..30}; do
    mysql -h ${db_endpoint} -u ${db_username} -p${db_password} -e "SHOW DATABASES;" && break
    echo "Esperando RDS..."
    sleep 10
done

# Importar dump
mysql -h ${db_endpoint} -u ${db_username} -p${db_password} ${db_name} < /tmp/dump.sql

echo "Importación completada"