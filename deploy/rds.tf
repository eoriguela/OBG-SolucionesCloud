# RDS MYSQL 5.7 MULTI-AZ
#############################################

resource "aws_db_subnet_group" "db_subnets" {
  name       = "db-subnets"                         # Nombre del grupo de subredes para RDS
  subnet_ids = aws_subnet.private[*].id             # Subredes privadas donde se desplegará el RDS

  tags = {
    Name = "${var.vpc_name}-db-subnets"             # Etiqueta identificando el grupo de subredes
  }
}

resource "aws_db_instance" "ecommerce" {
  identifier              = "ecommerce-db"           # Identificador único de la instancia RDS
  engine                  = "mysql"                  # Motor de base de datos utilizado
  engine_version          = "5.7"                    # Versión específica del motor MySQL
  instance_class          = var.db_instance_class    # Tamaño/clase de la instancia
  allocated_storage       = var.db_allocated_storage # Almacenamiento asignado en GB
  storage_type            = "gp2"                    # Tipo de almacenamiento general purpose
  multi_az                = true                     # Activación del despliegue Multi-AZ para alta disponibilidad

  db_name  = var.db_name                             # Nombre de la base de datos inicial
  username = var.db_username                         # Usuario administrador definido
  password = var.db_password                         # Contraseña del usuario administrador

  db_subnet_group_name   = aws_db_subnet_group.db_subnets.name  # Asociación al grupo de subredes
  vpc_security_group_ids = [aws_security_group.sg_db.id]         # Grupo de seguridad aplicado a la instancia

  backup_retention_period = var.db_backup_retention_days         # Cantidad de días para retención de backups
  skip_final_snapshot     = true                                 # Evita snapshot final al eliminar la instancia

  tags = {
    Name = "${var.vpc_name}-db"                     # Etiqueta de identificación para la instancia RDS
  }
}
