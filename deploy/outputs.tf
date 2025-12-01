output "vpc_id" {
  description = "ID de VPC"        # Descripción del output: muestra el ID de la VPC creada
  value       = aws_vpc.main.id    # Retorna el ID de la VPC principal
}

output "public_subnet_ids" {
  description = "IDs de public subnets"     # Descripción del output: lista IDs de subredes públicas
  value       = aws_subnet.public[*].id     # Devuelve una lista con los IDs de todas las subredes públicas
}

output "private_subnet_ids" {
  description = "IDs de private subnets"     # Descripción: IDs de las subredes privadas
  value       = aws_subnet.private[*].id     # Retorna una lista con los IDs de subredes privadas
}

output "internet_gateway_id" {
  description = "ID de Internet Gateway"     # Descripción: ID del Internet Gateway de la VPC
  value       = aws_internet_gateway.igw.id  # Retorna el ID del IGW creado
}

output "nat_gateway_ids" {
  description = "IDs de NAT Gateways"        # Descripción: IDs de los NAT Gateways
  value       = aws_nat_gateway.nat[*].id    # Devuelve una lista con los IDs de NATs (uno por AZ)
}

output "alb_dns_name" {
  description = "DNS público del Load Balancer"       # Descripción: URL del Application Load Balancer
  value       = "http://${aws_lb.alb.dns_name}"        # Devuelve el DNS del ALB formateado con http://
}
