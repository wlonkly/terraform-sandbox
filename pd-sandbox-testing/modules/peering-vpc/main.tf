variable "name" {}
variable "cidr_block" {}
variable "region" {}
variable "keypair" {}

resource "aws_vpc" "vpc" {
  cidr_block           = "${var.cidr_block}/24"
  enable_dns_hostnames = true

  tags = {
    Name  = "rlafferty-peering-test-vpc-${var.name}"
    owner = "rlafferty"
  }
}

resource "aws_subnet" "subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "${var.cidr_block}/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  tags = {
    Name  = "rlafferty-peering-test-sn-${var.name}"
    owner = "rlafferty"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name  = "rlafferty-peering-test-igw-${var.name}"
    owner = "rlafferty"
  }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name  = "rlafferty-peering-test-rt-${var.name}"
    owner = "rlafferty"
  }
}

resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.rt.id
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = var.keypair
  subnet_id     = aws_subnet.subnet.id

  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.sg.id]

  tags = {
    Name  = "rlafferty-peering-test-ec2-${var.name}"
    owner = "rlafferty"
  }
}

resource "aws_security_group" "sg" {
  name        = "rlafferty-peering-test-sg"
  description = "Peering test: Allow SSH from home"
  vpc_id      = aws_vpc.vpc.id
}

resource "aws_security_group_rule" "sgr" {
  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"
  cidr_blocks = [
    "24.212.233.114/32", # rich at home
    "0.0.0.0/0",
  ]

  security_group_id = aws_security_group.sg.id
}

resource "aws_security_group_rule" "allow_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg.id
}

output "public_dns" {
  value = aws_instance.instance.public_dns
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}
