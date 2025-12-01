# Security Groups y NACL
# Un SG por recurso para brindar un mayor nivel de control
#############################################

# Security Group del Load Balancer público
resource "aws_security_group" "sg_lb" {
  name        = "${var.vpc_name}-lb-sg"                       # Nombre del SG basado en la VPC
  description = "Security Group del Load Balancer publico"    # Descripción del SG
  vpc_id      = aws_vpc.main.id                               # Asociado a la VPC principal

  # Regla de entrada HTTP desde cualquier origen
  ingress {
    description = "HTTP publico"                              # Permite tráfico HTTP
    from_port   = 80                                          # Puerto 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]                               # Acceso abierto
  }

  # Regla de entrada HTTPS desde cualquier origen
  ingress {
    description = "HTTPS publico"                             # Permite tráfico HTTPS
    from_port   = 443                                         # Puerto 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]                               # Acceso abierto
  }

  # Regla de salida hacia cualquier destino (uso habitual en ALB)
  egress {
    from_port   = 0                                           # Todo tráfico
    to_port     = 0
    protocol    = "-1"                                        # Cualquier protocolo
    cidr_blocks = ["0.0.0.0/0"]                               # Libre salida
  }

  tags = {
    Name = "${var.vpc_name}-lb-sg"                            # Etiqueta
  }
}

# Security Group para los servidores de aplicación
resource "aws_security_group" "sg_app" {
  name        = "${var.vpc_name}-app-sg"                      # Nombre del SG
  description = "Security Group de servidores de aplicacion"  # Descripción del SG
  vpc_id      = aws_vpc.main.id                               # Asociado a la VPC

  # Entrada HTTP permitida solo desde el Load Balancer
  ingress {
    description     = "Trafico HTTP desde ALB"               # Tráfico controlado desde ALB
    from_port       = 80                                     # Puerto 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_lb.id]          # Origen limitado al SG del LB
  }

  # Entrada SSH con fines administrativos de laboratorio
  ingress {
    description = "SSH administrativo"                       # Acceso administrativo
    from_port   = 22                                         # Puerto 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]                               # Abierto al mundo (solo laboratorio)
  }

  # Salida general hacia toda la VPC o Internet
  egress {
    description = "Salida hacia toda la VPC"                 # Permite instalación de paquetes
    from_port   = 0                                          # Todos los puertos
    to_port     = 0
    protocol    = "-1"                                       # Cualquier protocolo
    cidr_blocks = ["0.0.0.0/0"]                              # Salida libre
  }

  tags = {
    Name = "${var.vpc_name}-app-sg"                          # Etiqueta
  }
}

#############################################
# Security Group para la Base de Datos MySQL (RDS)
#############################################

resource "aws_security_group" "sg_db" {
  name        = "${var.vpc_name}-db-sg"                       # Nombre del SG
  description = "Security Group de RDS MySQL"                 # Descripción
  vpc_id      = aws_vpc.main.id                               # VPC asociada

  # Permite acceso MySQL desde los servidores de aplicación
  ingress {
    description     = "MySQL desde instancias de aplicacion" # Acceso a puerto 3306
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_app.id]          # Solo desde SG de aplicación
  }

  # Acceso MySQL desde el servidor de backups
  ingress {
    description     = "MySQL desde servidor de Backups"       # Permite al servidor de backups conectarse
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_backup.id]       # Solo desde SG de backup
  }

  # Acceso MySQL desde el Bastion Host
  ingress {
    description     = "MySQL desde Bastion"                   # Acceso desde bastion
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_bastion.id]      # Origen: SG de bastion
  }

  # Salida general (normal en RDS gestionado por AWS)
  egress {
    from_port   = 0                                           # Todo tráfico
    to_port     = 0
    protocol    = "-1"                                        # Cualquier protocolo
    cidr_blocks = ["0.0.0.0/0"]                               # Salida libre
  }

  tags = {
    Name = "${var.vpc_name}-db-sg"                            # Etiqueta
  }
}

#############################################
# Security Group del Servidor de Backups
#############################################

resource "aws_security_group" "sg_backup" {
  name        = "${var.vpc_name}-backup-sg"                   # Nombre del SG
  description = "Security Group para servidor de backups"     # Descripción
  vpc_id      = aws_vpc.main.id                               # VPC asociada

  # Permitir acceso SSH desde App Servers (para subir archivos)
  ingress {
    description = "Backups desde App Servers"                 # Tráfico entrante SSH
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]                               # Abierto por fines de laboratorio
  }

  # Permitir salida hacia RDS MySQL
  egress {
    description = "Salida hacia RDS"                          # Conexión a MySQL
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]                               # Salida abierta
  }

  # Salida general para acceso a S3 u otros servicios
  egress {
    description = "Salida general"                            # Permite uso de AWS CLI, S3, etc.
    from_port   = 0
    to_port     = 0
    protocol    = "-1"                                        # Todos los protocolos
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.vpc_name}-backup-sg"                        # Etiqueta
  }
}

#############################################
# Security Group para Bastion Host
#############################################

resource "aws_security_group" "sg_bastion" {
  name        = "${var.vpc_name}-bastion-sg"                  # Nombre del SG
  description = "Security Group para bastion host"            # Descripción
  vpc_id      = aws_vpc.main.id                               # VPC asociada

  # Entrada SSH desde Internet (solo entorno de laboratorio)
  ingress {
    description = "SSH"                                       # Acceso administrativo
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]                               # Abierto completamente
  }

  # Salida general hacia Internet y subredes privadas
  egress {
    from_port   = 0                                           # Todo tráfico
    to_port     = 0
    protocol    = "-1"                                        # Cualquier protocolo
    cidr_blocks = ["0.0.0.0/0"]                               # Sin restricciones
  }

  tags = {
    Name = "${var.vpc_name}-bastion-sg"                       # Etiqueta
  }
}
