provider "aws" {
  region = "${var.region}"
}

variable "environment_name" {
    description = "The name of the environment"
    default = "rlafferty-tf-test"
}

variable "vpc_id" {
  description = "The ID of the VPC that the RDS cluster will be created in"
  default = "vpc-2780945e"
}

variable "vpc_name" {
  description = "The name of the VPC that the RDS cluster will be created in"
  default = "vpc-rlafferty-eks"
}

variable "vpc_rds_subnet_ids" {
  description = "The ID's of the VPC subnets that the RDS cluster instances will be created in"
  default = "subnet-134bc058,subnet-3a395043"
}

variable "vpc_rds_security_group_id" {
    description = "The ID of the security group that should be used for the RDS cluster instances"
    default = "sg-a22b76d3"
}

variable "rds_master_username" {
  description = "The ID's of the VPC subnets that the RDS cluster instances will be created in"
  default = "dbuser"
}

variable "rds_master_password" {
  description = "The ID's of the VPC subnets that the RDS cluster instances will be created in"
  default = "temppass"
}


data "aws_availability_zones" "available" {}

resource "aws_rds_cluster" "aurora_cluster" {

    cluster_identifier            = "${var.environment_name}-aurora-cluster"
    database_name                 = "mydb"
    master_username               = "${var.rds_master_username}"
    master_password               = "${var.rds_master_password}"
    backup_retention_period       = 14
    preferred_backup_window       = "02:00-03:00"
    preferred_maintenance_window  = "wed:03:00-wed:04:00"
    db_subnet_group_name          = "${aws_db_subnet_group.aurora_subnet_group.name}"
    final_snapshot_identifier     = "${var.environment_name}-aurora-cluster"
    vpc_security_group_ids        = [
        "${var.vpc_rds_security_group_id}"
    ]

    tags {
        Name         = "${var.environment_name}-Aurora-DB-Cluster"
        VPC          = "${var.vpc_name}"
        Owner        = "rlafferty"
        ManagedBy    = "terraform"
        Environment  = "${var.environment_name}"
    }

    lifecycle {
        create_before_destroy = true
    }

}

resource "aws_rds_cluster_instance" "aurora_cluster_instance" {

    count                 = "${length(split(",", var.vpc_rds_subnet_ids))}"

    identifier            = "${var.environment_name}-aurora-instance-${count.index}"
    cluster_identifier    = "${aws_rds_cluster.aurora_cluster.id}"
    instance_class        = "db.t2.small"
    db_subnet_group_name  = "${aws_db_subnet_group.aurora_subnet_group.name}"
    publicly_accessible   = true

    tags {
        Name         = "${var.environment_name}-Aurora-DB-Instance-${count.index}"
        VPC          = "${var.vpc_name}"
        ManagedBy    = "terraform"
        Owner        = "rlafferty"
        Environment  = "${var.environment_name}"
    }

    lifecycle {
        create_before_destroy = true
    }

}

resource "aws_db_subnet_group" "aurora_subnet_group" {

    name          = "${var.environment_name}_aurora_db_subnet_group"
    description   = "Allowed subnets for Aurora DB cluster instances"
    subnet_ids    = [
        "${split(",", var.vpc_rds_subnet_ids)}"
    ]

    tags {
        Name         = "${var.environment_name}-Aurora-DB-Subnet-Group"
        VPC          = "${var.vpc_name}"
        ManagedBy    = "terraform"
        Owner        = "rlafferty"
        Environment  = "${var.environment_name}"
    }

}

########################
## Output
########################

