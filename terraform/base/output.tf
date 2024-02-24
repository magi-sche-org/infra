output "vpc_id" {
  value = aws_vpc.main.arn
}

output "public_subnet_1a_id" {
  value = aws_subnet.public_1a.id
}

output "public_subnet_1c_id" {
  value = aws_subnet.public_1c.id
}

output "public_subnet_1d_id" {
  value = aws_subnet.public_1d.id
}

output "private_subnet_1a_id" {
  value = aws_subnet.private_1a.id
}

output "private_subnet_1c_id" {
  value = aws_subnet.private_1c.id
}

output "private_subnet_1d_id" {
  value = aws_subnet.private_1d.id
}
