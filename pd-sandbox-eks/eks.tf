module "my-cluster" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "rlafferty-eks-cluster"
  cluster_version = "1.17"
  subnets         = aws_subnet.subnet[*].id
  vpc_id          = aws_vpc.vpc.id
  iam_path        = "/terraform/"
  cluster_create_security_group = true

  worker_groups = [
    {
      instance_type = "t3.micro"
      asg_max_size  = 3
    }
  ]
}
