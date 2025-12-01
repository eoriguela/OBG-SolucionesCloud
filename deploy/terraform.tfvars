aws_region           = "us-east-1"                # Región de AWS donde se desplegará toda la infraestructura
vpc_cidr             = "10.0.0.0/16"              # Bloque CIDR principal para la VPC
vpc_name             = "obligatorio-vpc"          # Nombre base para los recursos asociados a la VPC
availability_zones   = ["us-east-1a", "us-east-1b"]  # Zonas de disponibilidad usadas para alta disponibilidad
public_subnet_cidrs  = ["10.0.0.0/24", "10.0.1.0/24"] # Subredes públicas dentro de la VPC
public_subnet_names  = ["public-subnet-1", "public-subnet-2"] # Nombres personalizados para las subredes públicas
private_subnet_cidrs = ["10.0.2.0/24", "10.0.3.0/24"] # Subredes privadas donde estará el RDS y la App
private_subnet_names = ["private-subnet-3", "private-subnet-4"] # Nombres personalizados para subredes privadas
app_ami              = "ami-0b898040803850657"    # AMI utilizada por las instancias de la aplicación
instance_type        = "t3.micro"                 # Tipo de instancia EC2 para la aplicación
key_name             = "vockey"                   # Nombre de la clave SSH usada para acceder a las instancias

dump_bucket_name = "obligatorio-ecommerce-dump-2025" # Nombre del bucket donde se almacenará el dump inicial

bastion_ami           = "ami-0b898040803850657"   # AMI usada por el Bastion Host
bastion_instance_type = "t3.micro"                # Tipo de instancia para el Bastion Host

s3_bucket_name = "obligatorio-dump-bucket"        # Nombre del bucket donde se subirá el dump.sql


# Variables DB
db_name                  = "ecommerce"            # Nombre de la base de datos a crear en RDS
db_username              = "ecommerce_user"       # Usuario administrador para MySQL
db_password              = "Cambiar123!"          # Password del usuario de la base de datos
db_instance_class        = "db.t3.micro"          # Clase de instancia utilizada en RDS
db_allocated_storage     = 20                     # Almacenamiento asignado en GB
db_backup_retention_days = 30                     # Retención automática de backups en días
