data "aws_eks_cluster" "cluster" {
  name = module.my-cluster.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.my-cluster.cluster_id
}

module "my-cluster" {
  source          = "github.com/wlonkly/terraform-aws-eks"
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

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.9"
}
