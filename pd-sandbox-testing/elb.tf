#
# Some instances to SSH into, representing pd-infra-gw boxes
#
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

resource "aws_key_pair" "keypair" {
  key_name   = "rlafferty-lb-test"
  public_key = file("id_rsa.pagerduty.pub")
}

resource "aws_instance" "instance" {
  count         = 2
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.keypair.key_name
  subnet_id     = element(aws_subnet.subnet.*.id, count.index)

  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.allow_ssh_from_home.id]
  iam_instance_profile        = aws_iam_instance_profile.profile.name

  tags = {
    Name  = "rlafferty-alb-test-${count.index}"
    owner = "rlafferty"
  }
}

resource "aws_security_group" "allow_ssh_from_home" {
  name        = "rlafferty-ssh"
  description = "Allow SSH from home"
  vpc_id      = aws_vpc.vpc.id
}

resource "aws_security_group_rule" "allow_ssh_from_home" {
  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"
  cidr_blocks = [
    aws_vpc.vpc.cidr_block, # health checks from NLB
    "24.212.233.114/32",    # rich at home
    "0.0.0.0/0",
  ]

  security_group_id = aws_security_group.allow_ssh_from_home.id
}

resource "aws_security_group_rule" "allow_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.allow_ssh_from_home.id
}

output "instance_ips" {
  value = aws_instance.instance.*.public_ip
}

#
# An NLB in front of those instances
#
resource "aws_eip" "lb-eip" {
  count    = length(var.subnets)
}

resource "aws_lb" "ssh" {
  name               = "rlafferty-test-ssh-lb"
  internal           = false
  load_balancer_type = "network"

  dynamic "subnet_mapping" {
    for_each = range(length(var.subnets))

    content {
      subnet_id     = lookup(aws_subnet.subnet[subnet_mapping.key], "id")
      allocation_id = lookup(aws_eip.lb-eip[subnet_mapping.key], "id")
    }
  }

  tags = {
    Name  = "rlafferty-ssh-test-lb"
    owner = "rlafferty"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "tg" {
  name     = "rlafferty-test-ssh-lb-tg"
  port     = 22
  protocol = "TCP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    interval = 30
    protocol = "TCP"
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.ssh.arn
  port              = "22"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_route53_zone" "rlafferty" {
  name = var.dns_zone
}

resource "aws_route53_record" "lb" {
  zone_id = data.aws_route53_zone.rlafferty.zone_id
  name    = "nlb-test.${var.dns_zone}"
  type    = "A"

  alias {
    name                   = aws_lb.ssh.dns_name
    zone_id                = aws_lb.ssh.zone_id
    evaluate_target_health = true
  }
}

#
# Attach the instances to the NLB
#
resource "aws_lb_target_group_attachment" "test" {
  count            = length(var.subnets)
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = element(aws_instance.instance.*.id, count.index)
}

#
# Then put a Global Accelerator in front of the NLB.
# If we had multiple regions available we could point this at >1 NLB
#
# Important gotcha: GA->NLB does _not_ preserve client IP. AWS doesn't
# support that combination at all (only GA->ALB or GA->EC2), and
# besides, Terraform doesn't let you tweak the config bit (see
# https://github.com/terraform-providers/terraform-provider-aws/pull/11476
resource "aws_globalaccelerator_accelerator" "ssh" {
  name            = "rlafferty-test-sshga"
  ip_address_type = "IPV4"
  enabled         = true
}

resource "aws_globalaccelerator_listener" "ssh" {
  accelerator_arn = aws_globalaccelerator_accelerator.ssh.id
  client_affinity = "SOURCE_IP"
  protocol        = "TCP"

  port_range {
    from_port = 22
    to_port   = 22
  }
}

resource "aws_globalaccelerator_endpoint_group" "ssh" {
  listener_arn = aws_globalaccelerator_listener.ssh.id

  endpoint_configuration {
    endpoint_id = aws_lb.ssh.arn
    weight      = 100
  }

  # defaults keep getting set?
  health_check_path = ""
  health_check_port = "22"
}

# Why not an ALIAS record? They're ostensibly supported (you can do an
# ALIAS to a GA DNS name) but the Terraform GA provider doesn't output
# the DNS name. Luckily the IP addresses from a GA are guaranteed to be
# static (for the lifetime of the GA).
#
# See https://github.com/terraform-providers/terraform-provider-aws/issues/11579
resource "aws_route53_record" "ga" {
  zone_id = data.aws_route53_zone.rlafferty.zone_id
  name    = "ga-nlb-test.${var.dns_zone}"
  type    = "A"
  ttl     = 600
  records = aws_globalaccelerator_accelerator.ssh.ip_sets[0]["ip_addresses"]
}
