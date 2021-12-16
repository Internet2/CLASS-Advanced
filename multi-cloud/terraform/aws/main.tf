# Project grove TerraForm AWS

provider "aws" {
  region = var.region
  shared_credentials_file = var.credentials
}

resource "aws_vpc" "grove" {
  cidr_block = "10.0.0.0/16"
  assign_generated_ipv6_cidr_block = true
  tags = {
    Name="grove-net"
    grove="vpc"
  }
}

resource "aws_subnet" "grove" {
  vpc_id = aws_vpc.grove.id
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = true
  ipv6_cidr_block = cidrsubnet(aws_vpc.grove.ipv6_cidr_block,8,0)
  assign_ipv6_address_on_creation = true
  tags = {
    Name="grove-subnet"
    grove="subnet"
  }
}

resource "aws_security_group" "grove" {
  name = "grove-sg"
  vpc_id = aws_vpc.grove.id
  ingress {
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    protocol = "icmp"
    from_port = -1
    to_port = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol = "icmpv6"
    from_port = -1
    to_port = -1
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = [ aws_subnet.grove.cidr_block ]
    ipv6_cidr_blocks = [ aws_subnet.grove.ipv6_cidr_block ]
  }
  egress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = "grove-sg"
    grove = "security-group"
  }
}

resource "aws_internet_gateway" "grove" {
  vpc_id = aws_vpc.grove.id
  tags = {
    Name="grove-gw"
    grove="internet-gateway"
  }
}

resource "aws_route_table" "grove" {
  vpc_id = aws_vpc.grove.id
  
  route {
    gateway_id = aws_internet_gateway.grove.id
    cidr_block = "0.0.0.0/0"
  }

  route {
    gateway_id = aws_internet_gateway.grove.id
    ipv6_cidr_block = "::/0"
  }

  tags = {
    Name = "grove-route"
    grove = "route-table"
  }
}

resource "aws_route_table_association" "grove" {
  subnet_id = aws_subnet.grove.id
  route_table_id = aws_route_table.grove.id
}

data "aws_ami" "amzn2" {
  # default user is "ec2-user"
  most_recent = true

  filter {
    name = "name"
    values = ["amzn2-ami-hvm*"]
  }

  filter {
    name = "architecture"
    #values = ["arm64"]
    values = ["x86_64"]
  }
  owners = ["amazon"]

}

data "aws_ami" "debian" {
  # https://wiki.debian.org/Cloud/AmazonEC2Image/Buster
  # default user is "admin"
  most_recent = true

  filter {
    name = "architecture"
    values = ["x86_64"]
  }
  owners = ["136693071363"]  ## Debian Buster Owner

}

resource "aws_key_pair" "grove" {
  key_name = "grove-${var.username}"
  public_key = var.ssh_public_key
  tags = {
    Name = "grove-key"
    grove = "key-pair"
  }
}

resource "aws_instance" "grove" {
  ami = data.aws_ami.amzn2.id # AWS Educate
  #ami = data.aws_ami.debian.id
  #instance_type = "a1.medium" ## ARM
  #instance_type = "t3a.micro" ## AMD
  instance_type = "t2.micro" ## AWS Educate
  key_name = aws_key_pair.grove.id
  subnet_id = aws_subnet.grove.id
  vpc_security_group_ids = [aws_security_group.grove.id] 
  tags = {
    Name = "grove"
    grove = "aws-instance"
  }
}
