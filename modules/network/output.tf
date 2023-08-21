output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_1a_id" {
  value = aws_subnet.public_subnet_1a.id
}

output "public_subnet_1c_id" {
  value = aws_subnet.public_subnet_1c.id
}
