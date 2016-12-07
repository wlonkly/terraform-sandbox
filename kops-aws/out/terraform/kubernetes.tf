provider "aws" {
  region = "us-east-1"
}

resource "aws_autoscaling_group" "master-us-east-1a-masters-kops-rich-dev-ca" {
  name = "master-us-east-1a.masters.kops.rich-dev.ca"
  launch_configuration = "${aws_launch_configuration.master-us-east-1a-masters-kops-rich-dev-ca.id}"
  max_size = 1
  min_size = 1
  vpc_zone_identifier = ["${aws_subnet.us-east-1a-kops-rich-dev-ca.id}"]
  tag = {
    key = "KubernetesCluster"
    value = "kops.rich-dev.ca"
    propagate_at_launch = true
  }
  tag = {
    key = "Name"
    value = "master-us-east-1a.masters.kops.rich-dev.ca"
    propagate_at_launch = true
  }
  tag = {
    key = "k8s.io/role/master"
    value = "1"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "nodes-kops-rich-dev-ca" {
  name = "nodes.kops.rich-dev.ca"
  launch_configuration = "${aws_launch_configuration.nodes-kops-rich-dev-ca.id}"
  max_size = 3
  min_size = 3
  vpc_zone_identifier = ["${aws_subnet.us-east-1a-kops-rich-dev-ca.id}"]
  tag = {
    key = "KubernetesCluster"
    value = "kops.rich-dev.ca"
    propagate_at_launch = true
  }
  tag = {
    key = "Name"
    value = "nodes.kops.rich-dev.ca"
    propagate_at_launch = true
  }
  tag = {
    key = "k8s.io/role/node"
    value = "1"
    propagate_at_launch = true
  }
}

resource "aws_ebs_volume" "us-east-1a-etcd-events-kops-rich-dev-ca" {
  availability_zone = "us-east-1a"
  size = 20
  type = "gp2"
  encrypted = false
  tags = {
    KubernetesCluster = "kops.rich-dev.ca"
    Name = "us-east-1a.etcd-events.kops.rich-dev.ca"
    "k8s.io/etcd/events" = "us-east-1a/us-east-1a"
    "k8s.io/role/master" = "1"
  }
}

resource "aws_ebs_volume" "us-east-1a-etcd-main-kops-rich-dev-ca" {
  availability_zone = "us-east-1a"
  size = 20
  type = "gp2"
  encrypted = false
  tags = {
    KubernetesCluster = "kops.rich-dev.ca"
    Name = "us-east-1a.etcd-main.kops.rich-dev.ca"
    "k8s.io/etcd/main" = "us-east-1a/us-east-1a"
    "k8s.io/role/master" = "1"
  }
}

resource "aws_iam_instance_profile" "masters-kops-rich-dev-ca" {
  name = "masters.kops.rich-dev.ca"
  roles = ["${aws_iam_role.masters-kops-rich-dev-ca.name}"]
}

resource "aws_iam_instance_profile" "nodes-kops-rich-dev-ca" {
  name = "nodes.kops.rich-dev.ca"
  roles = ["${aws_iam_role.nodes-kops-rich-dev-ca.name}"]
}

resource "aws_iam_role" "masters-kops-rich-dev-ca" {
  name = "masters.kops.rich-dev.ca"
  assume_role_policy = "${file("data/aws_iam_role_masters.kops.rich-dev.ca_policy")}"
}

resource "aws_iam_role" "nodes-kops-rich-dev-ca" {
  name = "nodes.kops.rich-dev.ca"
  assume_role_policy = "${file("data/aws_iam_role_nodes.kops.rich-dev.ca_policy")}"
}

resource "aws_iam_role_policy" "masters-kops-rich-dev-ca" {
  name = "masters.kops.rich-dev.ca"
  role = "${aws_iam_role.masters-kops-rich-dev-ca.name}"
  policy = "${file("data/aws_iam_role_policy_masters.kops.rich-dev.ca_policy")}"
}

resource "aws_iam_role_policy" "nodes-kops-rich-dev-ca" {
  name = "nodes.kops.rich-dev.ca"
  role = "${aws_iam_role.nodes-kops-rich-dev-ca.name}"
  policy = "${file("data/aws_iam_role_policy_nodes.kops.rich-dev.ca_policy")}"
}

resource "aws_internet_gateway" "kops-rich-dev-ca" {
  vpc_id = "${aws_vpc.kops-rich-dev-ca.id}"
  tags = {
    KubernetesCluster = "kops.rich-dev.ca"
    Name = "kops.rich-dev.ca"
  }
}

resource "aws_key_pair" "kubernetes-kops-rich-dev-ca-9bc8e26136d037a5e94f56fdd726140e" {
  key_name = "kubernetes.kops.rich-dev.ca-9b:c8:e2:61:36:d0:37:a5:e9:4f:56:fd:d7:26:14:0e"
  public_key = "${file("data/aws_key_pair_kubernetes.kops.rich-dev.ca-9bc8e26136d037a5e94f56fdd726140e_public_key")}"
}

resource "aws_launch_configuration" "master-us-east-1a-masters-kops-rich-dev-ca" {
  name_prefix = "master-us-east-1a.masters.kops.rich-dev.ca-"
  image_id = "ami-4bb3e05c"
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.kubernetes-kops-rich-dev-ca-9bc8e26136d037a5e94f56fdd726140e.id}"
  iam_instance_profile = "${aws_iam_instance_profile.masters-kops-rich-dev-ca.id}"
  security_groups = ["${aws_security_group.masters-kops-rich-dev-ca.id}"]
  associate_public_ip_address = true
  user_data = "${file("data/aws_launch_configuration_master-us-east-1a.masters.kops.rich-dev.ca_user_data")}"
  root_block_device = {
    volume_type = "gp2"
    volume_size = 20
    delete_on_termination = true
  }
  lifecycle = {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "nodes-kops-rich-dev-ca" {
  name_prefix = "nodes.kops.rich-dev.ca-"
  image_id = "ami-4bb3e05c"
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.kubernetes-kops-rich-dev-ca-9bc8e26136d037a5e94f56fdd726140e.id}"
  iam_instance_profile = "${aws_iam_instance_profile.nodes-kops-rich-dev-ca.id}"
  security_groups = ["${aws_security_group.nodes-kops-rich-dev-ca.id}"]
  associate_public_ip_address = true
  user_data = "${file("data/aws_launch_configuration_nodes.kops.rich-dev.ca_user_data")}"
  root_block_device = {
    volume_type = "gp2"
    volume_size = 20
    delete_on_termination = true
  }
  lifecycle = {
    create_before_destroy = true
  }
}

resource "aws_route" "0-0-0-0--0" {
  route_table_id = "${aws_route_table.kops-rich-dev-ca.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.kops-rich-dev-ca.id}"
}

resource "aws_route_table" "kops-rich-dev-ca" {
  vpc_id = "${aws_vpc.kops-rich-dev-ca.id}"
  tags = {
    KubernetesCluster = "kops.rich-dev.ca"
    Name = "kops.rich-dev.ca"
  }
}

resource "aws_route_table_association" "us-east-1a-kops-rich-dev-ca" {
  subnet_id = "${aws_subnet.us-east-1a-kops-rich-dev-ca.id}"
  route_table_id = "${aws_route_table.kops-rich-dev-ca.id}"
}

resource "aws_security_group" "masters-kops-rich-dev-ca" {
  name = "masters.kops.rich-dev.ca"
  vpc_id = "${aws_vpc.kops-rich-dev-ca.id}"
  description = "Security group for masters"
  tags = {
    KubernetesCluster = "kops.rich-dev.ca"
    Name = "masters.kops.rich-dev.ca"
  }
}

resource "aws_security_group" "nodes-kops-rich-dev-ca" {
  name = "nodes.kops.rich-dev.ca"
  vpc_id = "${aws_vpc.kops-rich-dev-ca.id}"
  description = "Security group for nodes"
  tags = {
    KubernetesCluster = "kops.rich-dev.ca"
    Name = "nodes.kops.rich-dev.ca"
  }
}

resource "aws_security_group_rule" "all-master-to-master" {
  type = "ingress"
  security_group_id = "${aws_security_group.masters-kops-rich-dev-ca.id}"
  source_security_group_id = "${aws_security_group.masters-kops-rich-dev-ca.id}"
  from_port = 0
  to_port = 0
  protocol = "-1"
}

resource "aws_security_group_rule" "all-master-to-node" {
  type = "ingress"
  security_group_id = "${aws_security_group.nodes-kops-rich-dev-ca.id}"
  source_security_group_id = "${aws_security_group.masters-kops-rich-dev-ca.id}"
  from_port = 0
  to_port = 0
  protocol = "-1"
}

resource "aws_security_group_rule" "all-node-to-master" {
  type = "ingress"
  security_group_id = "${aws_security_group.masters-kops-rich-dev-ca.id}"
  source_security_group_id = "${aws_security_group.nodes-kops-rich-dev-ca.id}"
  from_port = 0
  to_port = 0
  protocol = "-1"
}

resource "aws_security_group_rule" "all-node-to-node" {
  type = "ingress"
  security_group_id = "${aws_security_group.nodes-kops-rich-dev-ca.id}"
  source_security_group_id = "${aws_security_group.nodes-kops-rich-dev-ca.id}"
  from_port = 0
  to_port = 0
  protocol = "-1"
}

resource "aws_security_group_rule" "https-external-to-master" {
  type = "ingress"
  security_group_id = "${aws_security_group.masters-kops-rich-dev-ca.id}"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "master-egress" {
  type = "egress"
  security_group_id = "${aws_security_group.masters-kops-rich-dev-ca.id}"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "node-egress" {
  type = "egress"
  security_group_id = "${aws_security_group.nodes-kops-rich-dev-ca.id}"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ssh-external-to-master" {
  type = "ingress"
  security_group_id = "${aws_security_group.masters-kops-rich-dev-ca.id}"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ssh-external-to-node" {
  type = "ingress"
  security_group_id = "${aws_security_group.nodes-kops-rich-dev-ca.id}"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_subnet" "us-east-1a-kops-rich-dev-ca" {
  vpc_id = "${aws_vpc.kops-rich-dev-ca.id}"
  cidr_block = "172.20.32.0/19"
  availability_zone = "us-east-1a"
  tags = {
    KubernetesCluster = "kops.rich-dev.ca"
    Name = "us-east-1a.kops.rich-dev.ca"
  }
}

resource "aws_vpc" "kops-rich-dev-ca" {
  cidr_block = "172.20.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    KubernetesCluster = "kops.rich-dev.ca"
    Name = "kops.rich-dev.ca"
  }
}

resource "aws_vpc_dhcp_options" "kops-rich-dev-ca" {
  domain_name = "ec2.internal"
  domain_name_servers = ["AmazonProvidedDNS"]
  tags = {
    KubernetesCluster = "kops.rich-dev.ca"
    Name = "kops.rich-dev.ca"
  }
}

resource "aws_vpc_dhcp_options_association" "kops-rich-dev-ca" {
  vpc_id = "${aws_vpc.kops-rich-dev-ca.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.kops-rich-dev-ca.id}"
}