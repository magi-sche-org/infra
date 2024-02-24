resource "aws_security_group" "lb" {
  name   = "magische-lb"
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "magische-lb"
  }
}
