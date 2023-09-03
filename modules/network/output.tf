output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_1a_id" {
  value = aws_subnet.public_subnet_1a.id
}

output "public_subnet_1c_id" {
  value = aws_subnet.public_subnet_1c.id
}

output "private_subnet_1a_id" {
  value = aws_subnet.private_subnet_1a.id
}

output "private_subnet_1c_id" {
  value = aws_subnet.private_subnet_1c.id
}

output "public_subnet_1a_arn" {
  value = aws_subnet.public_subnet_1a.arn
}

output "public_subnet_1c_arn" {
  value = aws_subnet.public_subnet_1c.arn
}
