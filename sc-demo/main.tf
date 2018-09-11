resource "aws_instance" "sc-example" {
  count           = "3"
  ami             = "ami-9526abf1"
  instance_type   = "t2.micro"
  key_name        = "rich id_rsa"
  subnet_id       = "subnet-9ac70ef3"
  security_groups = ["acg-WebDMZ"]

  tags = {
    terraform = "true"
  }
}

output "ip" {
    value = "${aws_instance.sc-example.*.public_ip}"
}
