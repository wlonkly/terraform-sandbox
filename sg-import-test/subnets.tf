resource "aws_subnet" "subnet-5dfa6807-imp-1830-taavi-subnet1" {
    vpc_id                  = "vpc-fe550287"
    cidr_block              = "10.0.1.0/24"
    availability_zone       = "us-west-2c"
    map_public_ip_on_launch = false

    tags {
        "Name" = "imp-1830-taavi-subnet1"
    }
}

resource "aws_subnet" "subnet-d31ab58b-subnet-d31ab58b" {
    vpc_id                  = "vpc-f31f3b97"
    cidr_block              = "172.30.2.0/24"
    availability_zone       = "us-west-2c"
    map_public_ip_on_launch = true

    tags {
    }
}

resource "aws_subnet" "subnet-ebc8a98f-sn-default" {
    vpc_id                  = "vpc-4992e32d"
    cidr_block              = "10.0.0.0/24"
    availability_zone       = "us-west-2b"
    map_public_ip_on_launch = false

    tags {
        "Name" = "sn-default"
    }
}

resource "aws_subnet" "subnet-f2a908b9-eks-vpc-Subnet01" {
    vpc_id                  = "vpc-ca114bb3"
    cidr_block              = "192.168.64.0/18"
    availability_zone       = "us-west-2a"
    map_public_ip_on_launch = false

    tags {
        "Purpose" = "For Marguerite to play around with EKS and CF during hackday"
        "aws:cloudformation:logical-id" = "Subnet01"
        "Name" = "eks-vpc-Subnet01"
        "kubernetes.io/cluster/marg-eks" = "shared"
        "Team" = "SRE"
        "aws:cloudformation:stack-id" = "arn:aws:cloudformation:us-west-2:864672256020:stack/eks-vpc/84d8d4a0-44cc-11e8-9e2c-503acbd4dc29"
        "aws:cloudformation:stack-name" = "eks-vpc"
    }
}

resource "aws_subnet" "subnet-134bc058-sn-rlafferty-eks-2a" {
    vpc_id                  = "vpc-2780945e"
    cidr_block              = "172.16.0.0/24"
    availability_zone       = "us-west-2a"
    map_public_ip_on_launch = false

    tags {
        "Name" = "sn-rlafferty-eks-2a"
        "kubernetes.io/cluster/rlafferty-eks" = "shared"
    }
}

resource "aws_subnet" "subnet-a7af28de-eks-vpc-Subnet02" {
    vpc_id                  = "vpc-ca114bb3"
    cidr_block              = "192.168.128.0/18"
    availability_zone       = "us-west-2b"
    map_public_ip_on_launch = false

    tags {
        "aws:cloudformation:stack-id" = "arn:aws:cloudformation:us-west-2:864672256020:stack/eks-vpc/84d8d4a0-44cc-11e8-9e2c-503acbd4dc29"
        "Name" = "eks-vpc-Subnet02"
        "aws:cloudformation:stack-name" = "eks-vpc"
        "kubernetes.io/cluster/marg-eks" = "shared"
        "aws:cloudformation:logical-id" = "Subnet02"
        "Purpose" = "For Marguerite to play around with EKS and CF during hackday"
        "Team" = "SRE"
    }
}

resource "aws_subnet" "subnet-2f96f164-mia-dnstesting" {
    vpc_id                  = "vpc-3d2cc045"
    cidr_block              = "172.16.0.0/24"
    availability_zone       = "us-west-2a"
    map_public_ip_on_launch = false

    tags {
        "Name" = "mia-dnstesting"
        "Team" = "SRE"
        "Purpose" = "DNS Troubleshooting"
    }
}

resource "aws_subnet" "subnet-81adcff7-subnet-81adcff7" {
    vpc_id                  = "vpc-f31f3b97"
    cidr_block              = "172.30.0.0/24"
    availability_zone       = "us-west-2a"
    map_public_ip_on_launch = true

    tags {
    }
}

resource "aws_subnet" "subnet-3a395043-sn-rlafferty-eks-2b" {
    vpc_id                  = "vpc-2780945e"
    cidr_block              = "172.16.16.0/24"
    availability_zone       = "us-west-2b"
    map_public_ip_on_launch = false

    tags {
        "kubernetes.io/cluster/rlafferty-eks" = "shared"
        "Name" = "sn-rlafferty-eks-2b"
    }
}

resource "aws_subnet" "subnet-7adc961e-sn-AJ-1" {
    vpc_id                  = "vpc-f31f3b97"
    cidr_block              = "172.30.1.0/24"
    availability_zone       = "us-west-2b"
    map_public_ip_on_launch = true

    tags {
        "Name" = "sn-AJ-1"
    }
}

resource "aws_subnet" "subnet-90ac11e9-imp-1830-taavi-subnet2" {
    vpc_id                  = "vpc-fe550287"
    cidr_block              = "10.0.2.0/24"
    availability_zone       = "us-west-2b"
    map_public_ip_on_launch = false

    tags {
        "Name" = "imp-1830-taavi-subnet2"
    }
}

