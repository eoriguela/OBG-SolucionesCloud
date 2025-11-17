aws_region           = "us-east-1"
vpc_cidr             = "10.0.0.0/16"
vpc_name             = "Obligatorio-vpc"
availability_zones   = ["us-east-1a", "us-east-1b"]
public_subnet_cidrs  = ["10.0.0.0/24", "10.0.1.0/24"]
public_subnet_names  = ["public-subnet-1", "public-subnet-2"]
private_subnet_cidrs = ["10.0.2.0/24", "10.0.3.0/24"]
private_subnet_names = ["private-subnet-3", "private-subnet-4"]
app_ami              = "ami-03c870feb7c37e4ff"
instance_type        = "t2.micro"
key_name             = "vockey"

# Variables DB
db_name                  = "ecommerce"
db_username              = "ecommerce_user"
db_password              = "Cambiar123!"
db_instance_class        = "db.t3.micro"
db_allocated_storage     = 20
db_backup_retention_days = 7