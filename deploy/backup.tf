# Resource EC2 que utilizamos como "servidor" de backups
resource "aws_instance" "backup_server" {
  ami                    = var.bastion_ami                          # AMI utilizada para la instancia de backup
  instance_type          = var.bastion_instance_type                 # Tipo de instancia definida por variable
  subnet_id              = aws_subnet.private[0].id                  # Ubicamos la instancia en la primera subred privada
  key_name               = var.key_name                              # Par de claves para acceso SSH
  iam_instance_profile   = "LabInstanceProfile"                      # Perfil IAM con permisos para S3, CloudWatch y otros servicios necesarios
  vpc_security_group_ids = [aws_security_group.sg_backup.id]         # Grupo de seguridad específico para el servidor de backups

  # user_data generado a partir de una plantilla.
  # En este bloque pasamos los parámetros necesarios para permitir que el script se conecte a la base de datos
  # y cargue los backups al bucket correspondiente.
  user_data = templatefile("${path.module}/backup_userdata.sh.tpl", {
    db_endpoint = aws_db_instance.ecommerce.address                  # Endpoint del RDS donde reside la base de datos
    db_username = var.db_username                                    # Usuario con permisos de lectura (dump)
    db_password = var.db_password                                    # Contraseña del usuario
    db_name     = var.db_name                                        # Nombre de la base de datos a respaldar
    s3_bucket   = "${var.vpc_name}-db-backups"                       # Bucket destino para almacenar los backups
  })

  tags = {
    Name = "${var.vpc_name}-backup-server"                           # Etiqueta para identificar la instancia
  }
}
