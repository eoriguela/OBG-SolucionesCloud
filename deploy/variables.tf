variable "aws_region" {
  description = "Región de AWS para desplegar los recursos"  # Región donde se desplegará toda la infraestructura
  type        = string                                       # Tipo string obligatorio
}

variable "vpc_cidr" {
  description = "Bloque CIDR para la VPC"                    # Rango de direcciones IP de la VPC
  type        = string
}

variable "vpc_name" {
  description = "Nombre para la VPC y prefijo para recursos dentro" # Nombre base usado para etiquetar recursos
  type        = string
}

variable "availability_zones" {
  description = "Zonas de disponibilidad para las subredes"  # Lista de AZs donde se crean subredes públicas y privadas
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "Bloques CIDR para subredes públicas (uno por AZ)" # Cada CIDR corresponde a una subred pública
  type        = list(string)
}

variable "public_subnet_names" {
  description = "Nombre para subredes públicas"               # Nombres descriptivos para las subredes públicas
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "Bloques CIDR para subredes privadas (uno por AZ)" # CIDR por subred privada
  type        = list(string)
}

variable "private_subnet_names" {
  description = "Nombre para subredes privadas"               # Nombres descriptivos para subredes privadas
  type        = list(string)
}

variable "instance_type" {
  description = "tipo de instancia EC2 para instancias de aplicación" # Tamaño de la instancia EC2
  type        = string
}

variable "app_ami" {
  description = "AMI ID para instancias de aplicación"        # Imagen del Amazon usada para los servidores de aplicación
  type        = string
}

variable "key_name" {
  description = "Nombre del KeyPair a usar para las instancias" # Clave SSH para acceder a EC2
  type        = string
}

# RDS
variable "db_name" {
  description = "Nombre de la base de datos"                  # Nombre inicial de la base creada en el RDS
  type        = string
}

variable "db_username" {
  description = "Usuario administrador de la base de datos"   # Username principal del motor MySQL
  type        = string
}

variable "db_password" {
  description = "Password del usuario de la base de datos"    # Contraseña del usuario del RDS
  type        = string
  sensitive   = true                                          # Terraform oculta este valor en salidas y logs
}

variable "db_instance_class" {
  description = "Clase de instancia RDS (ej: db.t3.micro)"    # Tipo de instancia para la base
  type        = string
}

variable "db_allocated_storage" {
  description = "Almacenamiento en GB para RDS"               # Tamaño de almacenamiento asignado
  type        = number
}

variable "db_backup_retention_days" {
  description = "Días de retención de backups automáticos"    # Cuántos días RDS mantiene backups automáticos
  type        = number
}

variable "dump_bucket_name" {
  description = "Nombre del bucket S3 donde se sube el dump.sql" # Bucket para el archivo SQL inicial
  type        = string
}

variable "bastion_ami" {
  description = "AMI para el bastion (Amazon Linux 2)"        # Imagen usada para el Bastion Host
  type        = string
}

variable "bastion_instance_type" {
  description = "Tipo de instancia para el bastion"           # Tamaño del Bastion Host
  type        = string
}

variable "s3_bucket_name" {
  description = "Nombre del bucket donde está dump.sql"       # Bucket donde se alojará el dump cargado por Terraform
  type        = string
}
