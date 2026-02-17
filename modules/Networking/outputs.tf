output "vpc_id" {
  value = aws_vpc.multi_az_vpc.id
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnets[*].id
}

output "private_app_subnet_ids" {
  value = aws_subnet.private_app_subnets[*].id
}

output "private_db_subnet_ids" {
  value = aws_subnet.private_db_subnets[*].id
}

output "nat_gateway_ids" {
  value = aws_nat_gateway.nat_gateways[*].id
}
