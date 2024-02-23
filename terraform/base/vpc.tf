resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  enable_dns_support   = true
  enable_dns_hostnames = true

  assign_generated_ipv6_cidr_block = true

  tags = {
    Name = "magische-vpc"
  }
}

resource "aws_subnet" "public_1a" {
  vpc_id          = aws_vpc.main.id
  cidr_block      = cidrsubnet(aws_vpc.main.cidr_block, 4, 0)
  ipv6_cidr_block = cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, 0)

  map_public_ip_on_launch         = true
  availability_zone               = "ap-northeast-1a"
  assign_ipv6_address_on_creation = true

  tags = {
    Name = "magische-public-1a"
    Type = "public"
  }
}

resource "aws_subnet" "public_1b" {
  vpc_id          = aws_vpc.main.id
  cidr_block      = cidrsubnet(aws_vpc.main.cidr_block, 4, 1)
  ipv6_cidr_block = cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, 1)

  map_public_ip_on_launch         = true
  availability_zone               = "ap-northeast-1b"
  assign_ipv6_address_on_creation = true

  tags = {
    Name = "magische-public-1b"
    Type = "public"
  }
}

resource "aws_subnet" "public_1c" {
  vpc_id          = aws_vpc.main.id
  cidr_block      = cidrsubnet(aws_vpc.main.cidr_block, 4, 2)
  ipv6_cidr_block = cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, 2)

  map_public_ip_on_launch         = true
  availability_zone               = "ap-northeast-1c"
  assign_ipv6_address_on_creation = true

  tags = {
    Name = "magische-public-1c"
    Type = "public"
  }
}

resource "aws_subnet" "private_1a" {
  vpc_id          = aws_vpc.main.id
  cidr_block      = cidrsubnet(aws_vpc.main.cidr_block, 4, 3)
  ipv6_cidr_block = cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, 3)

  map_public_ip_on_launch         = false
  availability_zone               = "ap-northeast-1a"
  assign_ipv6_address_on_creation = true

  tags = {
    Name = "magische-private-1a"
    Type = "private"
  }
}

resource "aws_subnet" "private_1b" {
  vpc_id          = aws_vpc.main.id
  cidr_block      = cidrsubnet(aws_vpc.main.cidr_block, 4, 4)
  ipv6_cidr_block = cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, 4)

  map_public_ip_on_launch         = false
  availability_zone               = "ap-northeast-1b"
  assign_ipv6_address_on_creation = true

  tags = {
    Name = "magische-private-1b"
    Type = "private"
  }
}

resource "aws_subnet" "private_1c" {
  vpc_id          = aws_vpc.main.id
  cidr_block      = cidrsubnet(aws_vpc.main.cidr_block, 4, 5)
  ipv6_cidr_block = cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, 5)

  map_public_ip_on_launch         = false
  availability_zone               = "ap-northeast-1c"
  assign_ipv6_address_on_creation = true

  tags = {
    Name = "magische-private-1c"
    Type = "private"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "magische-public-route-table"
    Type = "public"
  }
}

resource "aws_route_table_association" "public_1a" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_1b" {
  subnet_id      = aws_subnet.public_1b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_1c" {
  subnet_id      = aws_subnet.public_1c.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "magische-private-route-table"
    Type = "private"
  }
}

resource "aws_route_table_association" "private_1a" {
  subnet_id      = aws_subnet.private_1a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_1b" {
  subnet_id      = aws_subnet.private_1b.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_1c" {
  subnet_id      = aws_subnet.private_1c.id
  route_table_id = aws_route_table.private.id
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "magische-internet-gateway"
  }
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.main.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "public_internet_gateway_ipv6" {
  route_table_id              = aws_route_table.public.id
  gateway_id                  = aws_internet_gateway.main.id
  destination_ipv6_cidr_block = "::/0"
}
