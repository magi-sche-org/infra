resource "aws_key_pair" "bastion" {
  key_name   = "bastion-${var.env}"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIME4sBu1MKOZ5nn2TG78fOXroUi9JQgqFQy6EKSdK2dM"
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.bastion.id
  instance_type               = "t2.nano"
  key_name                    = aws_key_pair.bastion.key_name
  subnet_id                   = var.api_ecs_config.subnet_ids[0]
  associate_public_ip_address = true
  vpc_security_group_ids = [
    aws_security_group.bastion.id,
  ]
  tags = {
    Name = "magische-${var.env}-bastion"
    Env  = var.env
  }
}

data "aws_ami" "bastion" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}
