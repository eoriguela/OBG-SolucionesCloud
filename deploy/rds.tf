# RDS MYSQL 5.7 MULTI-AZ
#############################################

resource "aws_db_subnet_group" "db_subnets" {
  name       = "db-subnets"   # debe ser minúsculas + guion
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "${var.vpc_name}-db-subnets"
  }
}

resource "aws_db_instance" "ecommerce" {
  identifier              = "ecommerce-db"   # ← nombre válido para AWS
  engine                  = "mysql"
  engine_version          = "5.7"
  instance_class          = var.db_instance_class
  allocated_storage       = var.db_allocated_storage
  storage_type            = "gp2"
  multi_az                = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.db_subnets.name
  vpc_security_group_ids = [aws_security_group.sg_db.id]

  backup_retention_period = var.db_backup_retention_days
  skip_final_snapshot     = true

  tags = {
    Name = "${var.vpc_name}-db"
  }
}