#!/bin/bash

yum update -y                     # Actualizamos todos los paquetes del sistema
yum install -y mysql awscli       # Instalamos el cliente MySQL y AWS CLI para realizar descargas desde S3

# Descargamos el archivo dump.sql desde el bucket S3 utilizando el rol IAM asignado a la instancia
aws s3 cp s3://${s3_bucket}/dump.sql /tmp/dump.sql

# Realizamos una espera activa para verificar que el RDS se encuentre accesible antes de iniciar la importación
for i in {1..30}; do
    mysql -h ${db_endpoint} -u ${db_username} -p${db_password} -e "SHOW DATABASES;" && break   # Validamos conectividad
    echo "Esperando RDS..."                                                                     # Indicamos estado de espera
    sleep 10                                                                                    # Retrasamos 10 segundos entre intentos
done

# Importamos el dump descargado hacia la base de datos definida
mysql -h ${db_endpoint} -u ${db_username} -p${db_password} ${db_name} < /tmp/dump.sql

echo "Importación completada"        # Confirmamos finalización del proceso
