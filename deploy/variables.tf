variable "aws_region" {
  description = "Región de AWS para desplegar los recursos"
  type        = string
}

variable "vpc_cidr" {
  description = "Bloque CIDR para la VPC"
  type        = string
}

variable "vpc_name" {
  description = "Nombre para la VPC y prefijo para recursos dentro"
  type        = string
}

variable "availability_zones" {
  description = "Zonas de disponibilidad para las subredes"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "Bloques CIDR para subredes públicas (uno por AZ)"
  type        = list(string)
}

variable "public_subnet_names" {
  description = "Nombre para subredes públicas"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "Bloques CIDR para subredes privadas (uno por AZ)"
  type        = list(string)
}

variable "private_subnet_names" {
  description = "Nombre para subredes privadas"
  type        = list(string)
}

variable "instance_type" {
  description = "tipo de instancia EC2 para instancias de aplicación"
  type        = string
  default     = "t3.micro"
}

variable "app_ami" {
  description = "AMI ID para instancias de aplicación"
  type        = string
  default     = "ami-03c870feb7c37e4ff"
}

variable "key_name" {
  description = "Nombre del KeyPair a usar para las instancias"
  type        = string
  default     = "vockey"
}

