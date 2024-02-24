resource "aws_route53_zone" "magische_net" {
  name          = "magi-sche.net"
  force_destroy = false

  tags = {
    Name = "magi-sche.net-zone"
  }
}
