resource "aws_security_group" "acg-terraform-WebDMZ" {
  name        = "acg-terraform-WebDMZ"
  description = "Allow HTTP and SSH"
  vpc_id      = "${aws_vpc.acg-terraform.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "acg-terraform-mysql" {
    name = "acg-terraform-mysql"
    description = "allow internal ssh, ping, mysql"
    vpc_id      = "${aws_vpc.acg-terraform.id}"


    ingress {
        from_port = 22
        to_port   = 22
        protocol  = "tcp"
        cidr_blocks = ["${aws_subnet.acg-terraform-10_0_1_0.cidr_block}"]
    }

    ingress {
        from_port = -1
        to_port   = -1
        protocol  = "icmp"
        cidr_blocks = ["${aws_subnet.acg-terraform-10_0_1_0.cidr_block}"]
    }

    ingress {
        from_port = 3306
        to_port   = 3306
        protocol  = "tcp"
        cidr_blocks = ["${aws_subnet.acg-terraform-10_0_1_0.cidr_block}"]
    }
}

resource "aws_instance" "acg-terraform-ec2-public" {
  ami            = "${lookup(var.amis, var.region)}"
  instance_type  = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.acg-terraform-WebDMZ.id}"]
  subnet_id      = "${aws_subnet.acg-terraform-10_0_1_0.id}"
  key_name       = "rich id_rsa"
  depends_on     = ["aws_internet_gateway.acg-terraform-igw"]
}


resource "aws_instance" "acg-terraform-ec2-private" {
  ami            = "${lookup(var.amis, var.region)}"
  instance_type  = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.acg-terraform-mysql.id}"]
  subnet_id      = "${aws_subnet.acg-terraform-10_0_2_0.id}"
  key_name       = "rich id_rsa"
}

output "public-instance-ip" {
    value = "${aws_instance.acg-terraform-ec2-public.public_ip}"
}


output "private-instance-ip" {
    value = "${aws_instance.acg-terraform-ec2-private.private_ip}"
}
