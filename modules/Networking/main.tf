resource "aws_vpc" "multi_az_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.tags, {
    Name = "multi-az-vpc"
  })
}

# Internet Gateway
resource "aws_internet_gateway" "multi_az_igw" {
  vpc_id = aws_vpc.multi_az_vpc.id

  tags = merge(var.tags, {
    Name = "multi-az-igw"
  })
}

# Public Subnets
resource "aws_subnet" "public_subnets" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.multi_az_vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "multi-az-public-${count.index + 1}"
  })
}

# Private App Subnets
resource "aws_subnet" "private_app_subnets" {
  count = length(var.private_app_subnet_cidrs)

  vpc_id            = aws_vpc.multi_az_vpc.id
  cidr_block        = var.private_app_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]

  tags = merge(var.tags, {
    Name = "multi-az-private-app-${count.index + 1}"
  })
}

# Private DB Subnets
resource "aws_subnet" "private_db_subnets" {
  count = length(var.private_db_subnet_cidrs)

  vpc_id            = aws_vpc.multi_az_vpc.id
  cidr_block        = var.private_db_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]

  tags = merge(var.tags, {
    Name = "multi-az-private-db-${count.index + 1}"
  })
}

# Elastic IPs for NAT
resource "aws_eip" "nat_eips" {
  count  = length(var.public_subnet_cidrs)
  domain = "vpc"
}

# NAT Gateways
resource "aws_nat_gateway" "nat_gateways" {
  count = length(var.public_subnet_cidrs)

  allocation_id = aws_eip.nat_eips[count.index].id
  subnet_id     = aws_subnet.public_subnets[count.index].id

  depends_on = [aws_internet_gateway.multi_az_igw]

  tags = merge(var.tags, {
    Name = "multi-az-nat-${count.index + 1}"
  })
}

# Public Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.multi_az_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.multi_az_igw.id
  }

  tags = merge(var.tags, {
    Name = "multi-az-public-rt"
  })
}

resource "aws_route_table_association" "public_associations" {
  count = length(aws_subnet.public_subnets)

  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

# Private Route Tables (one per AZ)
resource "aws_route_table" "private_route_tables" {
  count  = length(var.private_app_subnet_cidrs)
  vpc_id = aws_vpc.multi_az_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateways[count.index].id
  }

  tags = merge(var.tags, {
    Name = "multi-az-private-rt-${count.index + 1}"
  })
}

resource "aws_route_table_association" "private_app_associations" {
  count = length(aws_subnet.private_app_subnets)

  subnet_id      = aws_subnet.private_app_subnets[count.index].id
  route_table_id = aws_route_table.private_route_tables[count.index].id
}

resource "aws_route_table_association" "private_db_associations" {
  count = length(aws_subnet.private_db_subnets)

  subnet_id      = aws_subnet.private_db_subnets[count.index].id
  route_table_id = aws_route_table.private_route_tables[count.index].id
}
