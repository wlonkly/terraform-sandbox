resource "aws_security_group" "kops-permit-office" {
  name        = "rlafferty-kops-office-sg"
  description = "Allow inbound traffic from Toronto office"
  vpc_id      = "${aws_vpc.kops-vpc.id}"

  # unfortunately you can't have a "count" iterator INSIDE
  # a resource, you can only iteratively create resources.
  # TODO: see if there is an aws_security_group_ingress
  # resource that you can iterate on, and add the SF addresses
  # to the office_ips variable
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["108.63.21.218/32"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["72.139.16.94/32"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags {
    Name = "rlafferty-kops-office-sg"
    Owner = "rlafferty"
  }

}
