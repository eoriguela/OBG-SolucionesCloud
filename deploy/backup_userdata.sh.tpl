#!/bin/bash
set -xe

# Actualizar paquetes
yum update -y
yum install -y mariadb awscli

# Crear directorio de backups
mkdir -p /opt/db-backups
chmod 755 /opt/db-backups

# Crear script de backup (variables insertadas por Terraform)
cat << EOF > /usr/local/bin/mysql-backup.sh
#!/bin/bash

DATE=\$(date +%F_%H-%M)
FILE="/opt/db-backups/db-\$${DATE}.sql"

mysqldump -h ${db_endpoint} -u ${db_username} -p${db_password} ${db_name} > "\$FILE"

if [ \$? -eq 0 ]; then
  aws s3 cp "\$FILE" s3://${s3_bucket}/db-\$${DATE}.sql
else
  echo "Backup failed at \$(date)" >> /var/log/db-backup-error.log
fi
EOF

chmod +x /usr/local/bin/mysql-backup.sh


# Crear el cron correctamente en /etc/cron.d

cat <<EOF > /etc/cron.d/mysql-backup
# Ejecutar a las 02:00
0 2 * * * root /usr/local/bin/mysql-backup.sh

# Ejecutar a las 15:15 (modo prueba)
30 00 * * * root /usr/local/bin/mysql-backup.sh
EOF

chmod 644 /etc/cron.d/mysql-backup

systemctl enable crond
systemctl restart crond