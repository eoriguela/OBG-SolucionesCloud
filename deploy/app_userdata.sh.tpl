#!/bin/bash
set -xe   # Activo modo debug (-x) y que falle si algo sale mal (-e)

# Instalación de PHP 5.4 

amazon-linux-extras enable epel          # Habilitamos EPEL
yum install -y epel-release              # Instalamos repositorio EPEL
yum install -y http://rpms.remirepo.net/enterprise/remi-release-7.rpm   # Agrego repo Remi
yum-config-manager --enable remi-php54   # Habilitamos específicamente PHP 5.4
yum install -y php php-cli php-common php-mbstring php-xml php-mysql php-fpm   # Instalo PHP + módulos necesarios

# Iniciar Apache — servidor web de la app

yum install -y httpd             # Instalo Apache
systemctl enable httpd           # Lo habilito para que arranque con el sistema
systemctl start httpd            # Lo inicio

# Instalar MySQL 5.7 client 

yum install -y php-mysql.x86_64  # Cliente MySQL para PHP

# Crear destino de la app — preparo el docroot de Apache

mkdir -p /var/www/html           # Creamos la carpeta de la app
chmod -R 755 /var/www/html       # Permisos básicos para lectura y ejecución

# Descargar app desde S3 — utilizando el zip que subí previamente al bucket

aws s3 cp s3://${app_bucket}/app.zip /tmp/app.zip   # Descargo la app

if [ ! -f /tmp/app.zip ]; then                      # Valido que el archivo realmente descargó
  echo "ERROR: No se pudo descargar /tmp/app.zip" >> /var/log/userdata-error.log
  exit 1                                            # Si no existe, finaliza ejecución
fi

# Descomprimir app — dejo todo en /tmp para después moverlo

unzip -o /tmp/app.zip -d /tmp/app   # Descomprimo el ZIP

# Copiar a /var/www/html — desplegamos la aplicación

cp -r /tmp/app/* /var/www/html/     # Copio todos los archivos al docroot

# Permisos — Apache necesita poder leer y ejecutar

chown -R apache:apache /var/www/html   # Cambio dueño a apache
chmod -R 755 /var/www/html             # Ajusto permisos

# Reiniciar Apache para tomar todos los cambios

systemctl restart httpd

# --- Crear config.php  ---
# Generamos archivo de configuración con las variables que vienen desde Terraform (DB host, user, pass, etc.)

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


##############################
# Instalar CloudWatch Agent — para monitorear CPU, RAM, disco, etc.

yum install -y amazon-cloudwatch-agent   # Instalo el agente de CloudWatch


#Configuración del agente — métricas que quiero enviar a CW

cat <<'EOF' > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
  "metrics": {
    "append_dimensions": {
      "AutoScalingGroupName": "$${aws:AutoScalingGroupName}",  # Adjunta el ASG
      "InstanceId": "$${aws:InstanceId}"                       # Adjunta el ID de la instancia
    },
    "metrics_collected": {
      "mem": {                                                # Métrica de memoria
        "measurement": [ "mem_used_percent" ]
      },
      "cpu": {                                                # Métricas de CPU
        "measurement": [
          "cpu_usage_idle",
          "cpu_usage_user",
          "cpu_usage_system"
        ],
        "totalcpu": true
      },
      "disk": {                                               # Métricas de disco
        "measurement": [ "used_percent" ],
        "resources": [ "*" ]
      }
    }
  }
}
EOF


# 4. Iniciar el CloudWatch Agent — aplico la configuración y levanto el agente

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
  -s   # -s = start, arranca el servicio
