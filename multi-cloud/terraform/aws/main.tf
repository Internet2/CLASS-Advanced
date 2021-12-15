# Project Zero TerraForm AWS

resource "aws_vpc" "zero" {
  cidr_block = "10.0.0.0/16"
  assign_generated_ipv6_cidr_block = true
  tags = {
    Name="zero-net"
    zero="vpc"
  }
}

resource "aws_subnet" "zero" {
  vpc_id = aws_vpc.zero.id
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = true
  ipv6_cidr_block = cidrsubnet(aws_vpc.zero.ipv6_cidr_block,8,0)
  assign_ipv6_address_on_creation = true
  tags = {
    Name="zero-subnet"
    zero="subnet"
  }
}

resource "aws_security_group" "zero" {
  name = "zero-sg"
  vpc_id = aws_vpc.zero.id
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
    cidr_blocks = [ aws_subnet.zero.cidr_block ]
    ipv6_cidr_blocks = [ aws_subnet.zero.ipv6_cidr_block ]
  }
  egress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = "zero-sg"
    zero = "security-group"
  }
}

resource "aws_internet_gateway" "zero" {
  vpc_id = aws_vpc.zero.id
  tags = {
    Name="zero-gw"
    zero="internet-gateway"
  }
}

resource "aws_route_table" "zero" {
  vpc_id = aws_vpc.zero.id
  
  route {
    gateway_id = aws_internet_gateway.zero.id
    cidr_block = "0.0.0.0/0"
  }

  route {
    gateway_id = aws_internet_gateway.zero.id
    ipv6_cidr_block = "::/0"
  }

  tags = {
    Name = "zero-route"
    zero = "route-table"
  }
}

resource "aws_route_table_association" "zero" {
  subnet_id = aws_subnet.zero.id
  route_table_id = aws_route_table.zero.id
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

resource "aws_key_pair" "zero" {
  key_name = "zero-${var.username}"
  public_key = var.ssh_public_key
  tags = {
    Name = "zero-key"
    zero = "key-pair"
  }
}

resource "aws_instance" "zero" {
  #ami = data.aws_ami.amzn2.id
  ami = data.aws_ami.debian.id
  #instance_type = "a1.medium" ## ARM
  #instance_type = "t3a.micro" ## AMD
  instance_type = "t2.micro" ## AWS Educate
  key_name = aws_key_pair.zero.id
  subnet_id = aws_subnet.zero.id
  vpc_security_group_ids = [aws_security_group.zero.id] 
  tags = {
    Name = "zero"
    zero = "aws-instance"
  }
}
