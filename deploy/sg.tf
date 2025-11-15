# Security Groups y NACL
# Un SG por resource para mayor control
#############################################

#Load Balancer Security Group
resource "aws_security_group" "sg_lb" {
  name        = "lb_sg"
  description = "Security Group del Load Balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP publico"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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
}


#App Server Security Group
resource "aws_security_group" "sg_app" {
  name        = "app_sg"    #Redefinir
  description = "Security Group para los servidores de aplicacion"
  vpc_id      = aws_vpc.main.id

  # Los App Servers solo aceptan tráfico del LB
  ingress {
    description     = "Trafico desde ALB"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_lb.id]
  }

  # Salida hacia DB y Backup
  egress {
    from_port       = 0     
    to_port         = 0   # Puerto a editar previa designación db,posiblemente PostgreSQL (5432)
    protocol        = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "app_sg" # Redefinir
  }
}

# DB Security Group
resource "aws_security_group" "sg_db" {
  name        = "db_sg" #Redefinir
  description = "Security Group para Base de Datos"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "acceso DB desde de aplicacion"
    from_port       = 5432
    to_port         = 5432     # Puerto PostgreSQL 
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_app.id]
  }

  # La DB envíaría tráfico solo si lo necesita (backups)
  egress {
    from_port       = 0
    to_port         = 0 
    protocol        = "-1"
     cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "db_sg"  # Redefinir
  }
}


# Backup Server Security Group
resource "aws_security_group" "sg_backup" {
  name        = "backup_sg"
  description = "Security Group para Servidor de Backups"
  vpc_id      = aws_vpc.main.id

  ## Restan realizar reglas ingress y de salida hacia db y app srvers
}

  