# Security Groups y NACL
# Un SG por resource para mayor control
#############################################

#Load Balancer Security Group

resource "aws_security_group" "sg_lb" {
  name        = "${var.vpc_name}-lb-sg"
  description = "Security Group del Load Balancer publico"
  vpc_id      = aws_vpc.main.id

  # HTTP publico
  ingress {
    description = "HTTP publico"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS publico (para conexiones SSL)
  ingress {
    description = "HTTPS publico"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Salida hacia App Servers
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.vpc_name}-lb-sg"
  }
}



#App Server Security Group

resource "aws_security_group" "sg_app" {
  name        = "${var.vpc_name}-app-sg"
  description = "Security Group de servidores de aplicacion"
  vpc_id      = aws_vpc.main.id

  # Trafico HTTP desde el ALB
  # Los App Servers solo aceptan tráfico del LB
  ingress {
    description     = "Trafico HTTP desde ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_lb.id]
  }

  # SSH permitido desde cualquier IP o rango autorizado
  ingress {
    description = "SSH administrativo"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #Se permiten conexiones desde cualquier lugar con fines de laboratorio
  }

  # Salida a todas las subredes privadas (DB y Backups)
  egress {
    description = "Salida hacia toda la VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] #Se permite salida general para poder instalar desde internet
  }

  tags = {
    Name = "${var.vpc_name}-app-sg"
  }
}

# DB Security Group
# SG de Base de datos (MySql RDS MULTI-AZ)
#############################################

resource "aws_security_group" "sg_db" {
  name        = "${var.vpc_name}-db-sg"
  description = "Security Group de RDS MySQL"
  vpc_id      = aws_vpc.main.id

  # MySQL permitido desde servidores de aplicación
  ingress {
    description     = "MySQL desde instancias de aplicacion"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_app.id]
  }

  # Permitir trafico del servidor de backups
  ingress {
    description     = "MySQL desde servidor de Backups"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_backup.id]
  }

  # MySQL desde Bastion
  ingress {
    description     = "MySQL desde Bastion"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_bastion.id]
  }

  # Salida general (normal en RDS)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.vpc_name}-db-sg"
  }
}

# Backup Server Security Group
resource "aws_security_group" "sg_backup" {
  name        = "${var.vpc_name}-backup-sg"
  description = "Security Group para servidor de backups"
  vpc_id      = aws_vpc.main.id

  # Permitir conexiones desde App Servers (para subir backups)
  ingress {
    description     = "Backups desde App Servers"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permitir salida hacia RDS
  egress {
    description = "Salida hacia RDS"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Salida general (si se requiere para servicios S3 o LB)
  egress {
    description = "Salida general"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.vpc_name}-backup-sg"
  }
}

# Bastion Security Group
resource "aws_security_group" "sg_bastion" {
  name        = "${var.vpc_name}-bastion-sg"
  description = "Security Group para bastion host"
  vpc_id      = aws_vpc.main.id

  # SSH desde Internet (solo laboratorio)
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Salida a Internet (y también a la VPC)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.vpc_name}-bastion-sg"
  }
}