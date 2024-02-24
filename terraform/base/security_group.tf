resource "aws_security_group" "lb" {
  name   = "magische-lb"
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "magische-lb"
  }
}

# allow ingress from cloudfront
data "aws_ec2_managed_prefix_list" "cloudfront" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

resource "aws_security_group_rule" "lb_ingress_cloudfront" {
  security_group_id = aws_security_group.lb.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  prefix_list_ids   = [data.aws_ec2_managed_prefix_list.cloudfront.id]
}
