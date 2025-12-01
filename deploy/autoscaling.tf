# Envia la variable ${app_bucket} al script
# Este bloque procesa la plantilla del script de user_data e inyecta las variables necesarias para
# establecer la conexión entre la instancia EC2 y la base de datos en RDS.

data "template_file" "app_userdata" {
  template = file("${path.module}/app_userdata.sh.tpl")   # Cargamos el archivo de plantilla user_data

  # Parámetros que pasamos al script para la correcta configuración de la aplicación
  vars = {
    app_bucket = aws_s3_bucket.app_bucket.bucket          # Nombre del bucket S3 donde reside la aplicación
    db_endpoint = aws_db_instance.ecommerce.address       # Endpoint del RDS al que deberá conectarse la aplicación
    db_username = var.db_username                         # Usuario de la base de datos
    db_password = var.db_password                         # Contraseña del usuario de la base de datos
    db_name     = var.db_name                             # Nombre de la base utilizada por la aplicación
  }
}

# Plantilla de lanzamiento para las instancias del ASG
resource "aws_launch_template" "app_lt" {
  name_prefix   = "${var.vpc_name}-app-lt"                # Prefijo de la plantilla para facilitar identificación
  image_id      = var.app_ami                             # AMI utilizada para la aplicación
  instance_type = var.instance_type                       # Tipo de instancia EC2
  key_name      = var.key_name                            # Par de claves para acceso SSH

  network_interfaces {
    device_index    = 0
    security_groups = [aws_security_group.sg_app.id]      # Asignamos el SG correspondiente a la aplicación
    associate_public_ip_address = true                    # Asignamos IP pública para facilitar acceso y pruebas
  }
  
  iam_instance_profile {
    name = "LabInstanceProfile"                           # Perfil IAM con permisos para S3, CW y otros servicios
  }

  user_data = base64encode(data.template_file.app_userdata.rendered)   # User data generado dinámicamente

  lifecycle {
    create_before_destroy = true                          # Garantiza despliegues sin interrupción
  }
}

# Auto Scaling Group que gestionará las instancias de la aplicación
resource "aws_autoscaling_group" "asg_app" {
  name             = "${var.vpc_name}-asg-app"            # Nombre del ASG
  desired_capacity = 1                                    # Cantidad de instancias deseadas
  max_size         = 3                                    # Escalamiento máximo permitido
  min_size         = 1                                    # Mínimo de instancias activas

  # Subredes públicas donde desplegaremos las instancias
  vpc_zone_identifier = aws_subnet.public[*].id

  launch_template {
    id      = aws_launch_template.app_lt.id               # Vinculamos la plantilla de lanzamiento creada
    version = "$Latest"                                   # Utilizamos siempre la versión más reciente
  }

  # Asociación con el Target Group del ALB para balanceo de carga
  target_group_arns = [
    aws_lb_target_group.tg_app.arn
  ]

  tag {
    key                 = "Name"                          # Etiqueta estándar para identificar instancias
    value               = "${var.vpc_name}-app"
    propagate_at_launch = true                            # Propagamos la etiqueta a cada instancia creada
  }

  lifecycle {
    create_before_destroy = true                          # Aseguramos reemplazos sin downtime
  }
}
