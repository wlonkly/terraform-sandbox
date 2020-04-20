# Experiment to answer the question:
#
#   When you look up an AWS address like ec2-34-213-206-181.us-west-2.compute.amazonaws.com
#   from inside the VPC the instance is in, you get an internal address, and when you do it
#   from outside the VPC it's in, you get an Internet address. What happens when you look
#   it up from a peered VPC?
#
# Context: We depend on the public-address behavior to route cross-region requests
# across the IPsec mesh; if DNS behavior changes when we peer VPCs, that's going to
# complicate things greatly!


provider "aws" {
  region = "us-west-2"
  alias  = "usw2"
}

# Set up three VPCs with one subnet containing one instance:
# one in ca-central-1...
module "vpc-ca1" {
  source = "./modules/peering-vpc"

  region     = "ca-central-1"
  cidr_block = "10.44.0.0"
  name       = "ca1"
  keypair    = "rlafferty-lb-test"
}

# ... another in the SAME region ...
module "vpc-ca2" {
  source = "./modules/peering-vpc"

  region     = "ca-central-1"
  cidr_block = "10.44.1.0"
  name       = "ca2"
  keypair    = "rlafferty-lb-test"
}

# ... and another to test CROSS_region.
module "vpc-us1" {
  source = "./modules/peering-vpc"
  providers = {
    aws = aws.usw2
  }
  region     = "us-west-2"
  cidr_block = "10.44.2.0"
  name       = "us1"
  keypair    = "rlafferty-sandbox"
}

# Before peering is established, we have the expected public hostname DNS
# resolution behavior, here tested from a host in the "ca1" VPC:
# $ for i in ec2-15-223-69-154.ca-central-1.compute.amazonaws.com \
#            ec2-35-183-105-73.ca-central-1.compute.amazonaws.com \
#            ec2-54-186-130-255.us-west-2.compute.amazonaws.com; do host $i; done
# ec2-15-223-69-154.ca-central-1.compute.amazonaws.com has address 10.44.0.71
# ec2-35-183-105-73.ca-central-1.compute.amazonaws.com has address 35.183.105.73
# ec2-54-186-130-255.us-west-2.compute.amazonaws.com has address 54.186.130.255

# Peer the two VPCs in ca-central-1 with DNS resolution enabled in both directions.
resource "aws_vpc_peering_connection" "ca1-ca2" {
  vpc_id      = module.vpc-ca1.vpc_id
  peer_vpc_id = module.vpc-ca2.vpc_id

  auto_accept = true

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags = {
    Name  = "rlafferty-peering-test-ca1-ca2"
    owner = "rlafferty"
  }
}

# Cross-region, you need separate aws_vpc_peering_connection and
# aws_vpc_peering_connection_accepter resources, since each end is
# using a different provider...
resource "aws_vpc_peering_connection" "ca1-us1" {
  vpc_id      = module.vpc-ca1.vpc_id
  peer_vpc_id = module.vpc-us1.vpc_id
  peer_region = "us-west-2"

  auto_accept = false

  tags = {
    Name  = "rlafferty-peering-test-ca1-us1-requester"
    owner = "rlafferty"
  }
}

resource "aws_vpc_peering_connection_accepter" "ca1-us1" {
  provider                  = aws.usw2
  vpc_peering_connection_id = aws_vpc_peering_connection.ca1-us1.id
  auto_accept               = true

  tags = {
    Name  = "rlafferty-peering-test-ca1-us1-accepter"
    owner = "rlafferty"
  }
}

# ... and to work around dependencies, you need to set the remote
# DNS resolution flag after the peering connections have been established.
resource "aws_vpc_peering_connection_options" "ca1" {
  # As options can't be set until the connection has been accepted
  # create an explicit dependency on the accepter.
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.ca1-us1.id

  requester {
    allow_remote_vpc_dns_resolution = true
  }
}

resource "aws_vpc_peering_connection_options" "us1" {
  provider                  = aws.usw2
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.ca1-us1.id

  accepter {
    allow_remote_vpc_dns_resolution = true
  }
}

# And expected DNS behaviour:
# $ for i in ec2-15-223-69-154.ca-central-1.compute.amazonaws.com \
#            ec2-35-183-105-73.ca-central-1.compute.amazonaws.com \
#            ec2-54-186-130-255.us-west-2.compute.amazonaws.com; do host $i; done
# ec2-15-223-69-154.ca-central-1.compute.amazonaws.com has address 10.44.0.71
# ec2-35-183-105-73.ca-central-1.compute.amazonaws.com has address 10.44.1.172
# ec2-54-186-130-255.us-west-2.compute.amazonaws.com has address 10.44.2.211


# A note about Transit Gateway from https://aws.amazon.com/transit-gateway/features/
#
# Amazon VPC feature interoperability
# -----------------------------------
# AWS Transit Gateway enables the resolution of public DNS hostnames to private
# IP addresses when queried from Amazon VPCs that are also attached to the AWS
# Transit Gateway.
#
# An instance in an Amazon VPC can access a NAT gateway, Network Load Balancer,
# AWS PrivateLink, and Amazon Elastic File System in others Amazon VPCs that are
# also attached to the AWS Transit Gateway.


# Finally, output the DNS names for our DNS experiment.
output "ca1" {
  value = module.vpc-ca1.public_dns
}

output "ca2" {
  value = module.vpc-ca2.public_dns
}

output "us1" {
  value = module.vpc-us1.public_dns
}

