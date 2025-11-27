#!/bin/bash
set -xe

# Instalación de PHP 5.4

amazon-linux-extras enable epel
yum install -y epel-release
yum install -y http://rpms.remirepo.net/enterprise/remi-release-7.rpm
yum-config-manager --enable remi-php54
yum install -y php php-cli php-common php-mbstring php-xml php-mysql php-fpm

# Iniciar Apache

yum install -y httpd
systemctl enable httpd
systemctl start httpd

# Instalar MySQL 5.7 client

yum install -y php-mysql.x86_64

# Crear destino de la app

mkdir -p /var/www/html
chmod -R 755 /var/www/html

# Descargar app desde S3

aws s3 cp s3://${app_bucket}/app.zip /tmp/app.zip

if [ ! -f /tmp/app.zip ]; then
  echo "ERROR: No se pudo descargar /tmp/app.zip" >> /var/log/userdata-error.log
  exit 1
fi

# Descomprimir app

unzip -o /tmp/app.zip -d /tmp/app

# Copiar a /var/www/html
cp -r /tmp/app/* /var/www/html/

# Permisos

chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html

# Reiniciar Apache
systemctl restart httpd

# --- Crear config.php dinámico ---
cat <<EOF > /var/www/html/config.php
<?php
    ini_set('display_errors',1);
    error_reporting(-1);

    define('DB_HOST', '${db_endpoint}');
    define('DB_USER', '${db_username}');
    define('DB_PASSWORD', '${db_password}');
    define('DB_DATABASE', '${db_name}');
?>
EOF


# Instalar CloudWatch Agent

yum install -y amazon-cloudwatch-agent


# Crear configuración del agente

cat <<'EOF' > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
  "metrics": {
    "append_dimensions": {
      "AutoScalingGroupName": "$${aws:AutoScalingGroupName}",
      "InstanceId": "$${aws:InstanceId}"
    },
    "metrics_collected": {
      "mem": {
        "measurement": [ "mem_used_percent" ]
      },
      "cpu": {
        "measurement": [
          "cpu_usage_idle",
          "cpu_usage_user",
          "cpu_usage_system"
        ],
        "totalcpu": true
      },
      "disk": {
        "measurement": [ "used_percent" ],
        "resources": [ "*" ]
      }
    }
  }
}
EOF


# 4. Iniciar el CloudWatch Agent

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
  -s
