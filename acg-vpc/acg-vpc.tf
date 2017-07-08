provider "aws" {
  region     = "${var.region}"
}

# resource "aws_instance" "example" {
#   ami           = "${lookup(var.amis, var.region)}"
#   instance_type = "t2.micro"
# }

# output "ip" {
#     value = "${aws_instance.example.public_ip}"
# }

resource "aws_vpc" "acg-terraform" {
  cidr_block = "10.0.0.0/16"

  tags {
    Name = "acg-terraform"
  }
}

resource "aws_subnet" "acg-terraform-10_0_1_0" {
  vpc_id     = "${aws_vpc.acg-terraform.id}"
  cidr_block = "10.0.1.0/24"
  availability_zone = "${var.region}a"
  map_public_ip_on_launch = true

  tags {
    Name = "acg-terraform-10.0.1.0-${var.region}a"
  }
}

resource "aws_subnet" "acg-terraform-10_0_2_0" {
  vpc_id     = "${aws_vpc.acg-terraform.id}"
  cidr_block = "10.0.2.0/24"
  availability_zone = "${var.region}b"

  tags {
    Name = "acg-terraform-10.0.2.0-${var.region}b"
  }
}

resource "aws_internet_gateway" "acg-terraform-igw" {
  vpc_id = "${aws_vpc.acg-terraform.id}"

  tags {
    Name = "acg-terraform-igw"
  }
}

resource "aws_route_table" "acg-terraform-public-route" {
  vpc_id = "${aws_vpc.acg-terraform.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.acg-terraform-igw.id}"
  }

  tags {
    Name = "acg-terraform-public-route"
  }
}

resource "aws_route_table_association" "acg-terraform-public-route-a" {
  subnet_id      = "${aws_subnet.acg-terraform-10_0_1_0.id}"
  route_table_id = "${aws_route_table.acg-terraform-public-route.id}"
}

