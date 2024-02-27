resource "aws_route53_zone" "magische_net" {
  name          = "magi-sche.net"
  force_destroy = false

  tags = {
    Name = "magi-sche.net-zone"
  }
}

resource "aws_route53_zone" "magische_org" {
  name          = "magi-sche.org"
  force_destroy = false

  tags = {
    Name = "magi-sche.org-zone"
  }
}
