output "vpc_id" {
  description = "ID de VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs de public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs de private subnets"
  value       = aws_subnet.private[*].id
}

output "internet_gateway_id" {
  description = "ID de Internet Gateway"
  value       = aws_internet_gateway.igw.id
}

output "nat_gateway_ids" {
  description = "IDs de NAT Gateways"
  value       = aws_nat_gateway.nat[*].id
}

output "alb_dns_name" {
  description = "DNS público del Load Balancer"
  value       = "http://${aws_lb.alb.dns_name}"
}