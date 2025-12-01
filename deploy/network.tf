# Definición completa de la red en AWS, incluyendo VPC, subredes y tablas de ruteo.
# Implementamos una arquitectura distribuida y tolerante a fallos, utilizando dos zonas de disponibilidad.
#############################################

# VPC PRINCIPAL
#############################################
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr                       # Rango de direcciones de la VPC
  enable_dns_support   = true                               # Permitimos resolución DNS dentro de la VPC
  enable_dns_hostnames = true                               # Asignamos nombres DNS a las instancias con IP pública

  tags = {
    Name = var.vpc_name                                     # Etiqueta identificatoria de la VPC
  }
}

# INTERNET GATEWAY – permite salida directa a Internet
#############################################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id                                  # Asociamos el IGW a la VPC

  tags = {
    Name = "${var.vpc_name}-igw"                            # Etiqueta del IGW
  }
}

# SUBREDES PÚBLICAS – ubicadas en múltiples AZ
# Estas subredes poseen salida directa a Internet a través del IGW.
#############################################
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs) # Cantidad de counter según lista de subredes
  vpc_id                  = aws_vpc.main.id                 # VPC donde se crean las subredes
  cidr_block              = var.public_subnet_cidrs[count.index]  # Rango CIDR de cada subred
  availability_zone       = var.availability_zones[count.index]   # Zona de disponibilidad asociada
  map_public_ip_on_launch = true                             # Asignación automática de IP pública

  tags = {
    Name = var.public_subnet_names[count.index]             # Etiqueta correspondiente a cada subred pública
  }
}

# SUBREDES PRIVADAS – una por AZ
# Estas subredes no poseen salida directa y dependen del NAT Gateway.
#############################################
resource "aws_subnet" "private" {
  count                   = length(var.private_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false                           # No asignamos IP pública en subred privada

  tags = {
    Name = var.private_subnet_names[count.index]            # Etiqueta de cada subred privada
  }
}

# EIPs PARA NAT GATEWAYS – uno por zona de disponibilidad
# Cada NAT requiere un Elastic IP para brindarle salida a Internet a las subredes privadas.
#############################################
resource "aws_eip" "nat" {
  count = length(var.public_subnet_cidrs)

  tags = {
    Name = "${var.vpc_name}-nat-eip-${count.index + 1}"     # Identificamos el EIP según AZ
  }
}

# NAT GATEWAYS – ubicados en subredes públicas
# Su función es permitir que las instancias privadas accedan a Internet de forma segura.
#############################################
resource "aws_nat_gateway" "nat" {
  count         = length(var.public_subnet_cidrs)
  allocation_id = aws_eip.nat[count.index].id               # Asociamos cada NAT con su EIP correspondiente
  subnet_id     = aws_subnet.public[count.index].id         # Deben ubicarse en subred pública

  depends_on = [aws_internet_gateway.igw]                   # Garantizamos creación del IGW antes del NAT

  tags = {
    Name = "${var.vpc_name}-nat-${count.index + 1}"         # Identificación del NAT por zona
  }
}

# TABLA DE RUTAS PÚBLICA
# Todo el tráfico 0.0.0.0/0 se envía al Internet Gateway.
#############################################
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.vpc_name}-public-rt"                      # Etiqueta de la tabla de rutas pública
  }
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public.id        # Usamos la tabla pública
  destination_cidr_block = "0.0.0.0/0"                      # Ruta por defecto
  gateway_id             = aws_internet_gateway.igw.id      # Destino: IGW
}

resource "aws_route_table_association" "public_assoc" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id        # Asociamos cada subred pública
  route_table_id = aws_route_table.public.id
}

# TABLAS DE RUTAS PRIVADAS – una por AZ
# Cada tabla privada enruta la salida hacia su respectivo NAT Gateway.
#############################################
resource "aws_route_table" "private" {
  count  = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.vpc_name}-private-rt-${count.index + 1}"  # Identificación por AZ
  }
}

resource "aws_route" "private_route" {
  count                  = length(var.private_subnet_cidrs)
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"                      # Ruta por defecto
  nat_gateway_id         = aws_nat_gateway.nat[count.index].id  # Salida vía NAT correspondiente
}

resource "aws_route_table_association" "private_assoc" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id        # Asociación de subred privada con su tabla correspondiente
  route_table_id = aws_route_table.private[count.index].id
}
