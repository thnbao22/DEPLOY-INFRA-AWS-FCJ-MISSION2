resource "aws_vpc" "one-tier-vpc" {
  cidr_block            = var.cidr_block
  enable_dns_hostnames  = true
  enable_dns_support    = true
  tags = {
    Name = "vpc-workshop-2"
  }
}
# Public Subent 1 CIDR 10.10.1.0/24 in AZ ap-southeast-1a
resource "aws_subnet" "public_subnet_1" {
  vpc_id                    = aws_vpc.one-tier-vpc.id
  availability_zone         = var.availabitity_zones[0]
  cidr_block                = "10.10.1.0/24"
  map_public_ip_on_launch   = true
  tags = {
    "Name" = "Public Subnet 1"
  }
}
# Public Subent 2 CIDR 10.10.2.0/24 in AZ ap-southeast-1b
resource "aws_subnet" "public_subnet_2" {
  vpc_id                    = aws_vpc.one-tier-vpc.id
  availability_zone         = var.availabitity_zones[1]
  cidr_block                = "10.10.2.0/24"
  map_public_ip_on_launch   = true
  tags = {
    "Name" = "Public Subnet 2"
  }
}
# Internet Gateway
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
# Route to the internet
resource "aws_route" "public_route" {
  route_table_id            = aws_route_table.public_rt.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.one_tier_igw.id
}
# Associate the route table with the public subnet 1
resource "aws_route_table_association" "one_tier_rt_public_associate_1" {
  route_table_id    = aws_route_table.public_rt.id
  subnet_id         = aws_subnet.public_subnet_1.id
}
# Associate the route table with the public subnet 2
resource "aws_route_table_association" "one_tier_rt_public_associate_2" {
  route_table_id    = aws_route_table.public_rt.id
  subnet_id         = aws_subnet.public_subnet_2.id
}
# Retrieve the local IP address of your local machine
data "http" "local_ip" {
  url = "https://ipv4.icanhazip.com"
}
# Security Group for Auto Scaling Group EC2
resource "aws_security_group" "one_tier_public_sg" {
  name          = "Public Security Group"
  description   = "Allow HTTP and SSH inbound traffic"
  vpc_id        = aws_vpc.one-tier-vpc.id
  # Allow SSH from your local IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ "${chomp(data.http.local_ip.response_body)}/32" ]
  }
  # Allow HTTP traffic from the ALB to the Auto Scaling Group
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
# Security Group for Application Load Balancer
resource "aws_security_group" "one_tier_alb_sg" {
  name      = "ALB Security Group"
  vpc_id    = aws_vpc.one-tier-vpc.id
  # Allow HTTP request from the internet
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