resource "aws_vpc" "kops-vpc" {
  cidr_block = "${var.vpc_cidr_block}"

  tags {
    Name = "rlafferty-kops-vpc"
    Owner = "rlafferty"
  }
}

# whee! https://github.com/hashicorp/terraform/issues/58#issuecomment-172946037
resource "aws_subnet" "kops-subnet" {
  vpc_id            = "${aws_vpc.kops-vpc.id}"
  count             = "${length(var.azs)}"
  cidr_block        = "${cidrsubnet(var.vpc_cidr_block, 4, count.index)}"
  availability_zone = "${element(var.azs, count.index)}"
  map_public_ip_on_launch = false

    tags {
        "Name" = "rlafferty-kops-subnet-${element(var.azs, count.index)}-sn"
        "Owner" = "rlafferty"
    }
}

resource "aws_internet_gateway" "kops-igw" {
  vpc_id = "${aws_vpc.kops-vpc.id}"

  tags {
    Name = "rlafferty-kops-igw"
    Owner = "rlafferty"
  }
}


resource "aws_route_table" "kops-public-route" {
  vpc_id = "${aws_vpc.kops-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.kops-igw.id}"
  }

  tags {
    Name = "rlafferty-kops-public-route"
    Owner = "rlafferty"
  }
}

resource "aws_route_table_association" "kops-public-route" {
  count          = "${length(var.azs)}"
  subnet_id      = "${element(aws_subnet.kops-subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.kops-public-route.id}"
}
