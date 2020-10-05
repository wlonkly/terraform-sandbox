provider "aws" {
  region = var.region
}

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name  = "rlafferty-pd-eks-vpc"
    owner = "rlafferty"
  }
}

resource "aws_subnet" "subnet" {
  count = length(var.subnets)

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = element(values(var.subnets), count.index)
  availability_zone       = element(keys(var.subnets), count.index)
  map_public_ip_on_launch = true

  tags = {
    Name  = "rlafferty-test-eks-${count.index}"
    owner = "rlafferty"
  }
}

resource "aws_internet_gateway" "rlafferty-test-terraform-igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name  = "rlafferty-test-eks-igw"
    owner = "rlafferty"
  }
}

resource "aws_route_table" "rlafferty-test-terraform-public-route" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.rlafferty-test-terraform-igw.id
  }

  tags = {
    Name  = "rlafferty-test-eks-rt"
    owner = "rlafferty"
  }
}

resource "aws_route_table_association" "rta" {
  count          = length(var.subnets)
  subnet_id      = element(aws_subnet.subnet[*].id, count.index)
  route_table_id = aws_route_table.rlafferty-test-terraform-public-route.id
}

