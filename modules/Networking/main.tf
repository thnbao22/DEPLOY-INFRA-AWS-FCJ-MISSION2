resource "aws_vpc" "one-tier-vpc" {
  cidr_block            = var.cidr_block
  enable_dns_hostnames  = true
  enable_dns_support    = true
  tags = {
    Name = "vpc-workshop-2"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id                    = aws_vpc.one-tier-vpc.id
  availability_zone         = var.availabitity_zones[0]
  cidr_block                = "10.10.1.0/24"
  map_public_ip_on_launch   = true
  tags = {
    "Name" = "Public Subnet 1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                    = aws_vpc.one-tier-vpc.id
  availability_zone         = var.availabitity_zones[1]
  cidr_block                = "10.10.2.0/24"
  map_public_ip_on_launch   = true
  tags = {
    "Name" = "Public Subnet 2"
  }
}

resource "aws_internet_gateway" "one_tier_igw" {
  vpc_id = aws_vpc.one-tier-vpc.id
  tags = {
    "Name" = "Workshop2 IGW"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.one-tier-vpc.id
  tags = {
    "Name" = "Public Route Table"
  }
}

resource "aws_route" "public_route" {
  route_table_id            = aws_route_table.public_rt.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.one_tier_igw.id
}

resource "aws_route_table_association" "one_tier_rt_public_associate_1" {
  route_table_id    = aws_route_table.public_rt.id
  subnet_id         = aws_subnet.public_subnet_1.id
}

resource "aws_route_table_association" "one_tier_rt_public_associate_2" {
  route_table_id    = aws_route_table.public_rt.id
  subnet_id         = aws_subnet.public_subnet_2.id
}

data "http" "local_ip" {
  url = "https://ipv4.icanhazip.com"
}

resource "aws_security_group" "one_tier_public_sg" {
  name          = "Public Security Group"
  description   = "Allow HTTP and SSH inbound traffic"
  vpc_id        = aws_vpc.one-tier-vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ "${chomp(data.http.local_ip.response_body)}/32" ]
  }
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.one_tier_alb_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "one_tier_alb_sg" {
  name      = "ALB Security Group"
  vpc_id    = aws_vpc.one-tier-vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}