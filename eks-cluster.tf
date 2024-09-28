
variable "cluster_name" {}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.24.2"

  cluster_name    = var.cluster_name
  cluster_version = "1.30"

  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }


  vpc_id     = module.dlick-vpc.vpc_id
  subnet_ids = module.dlick-vpc.private_subnets

  tags = {
    Environment = "dev"
    Application = "dlick"
    Terraform   = "true"
  }

  eks_managed_node_groups = {
    dev = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      instance_types = ["t2.small"]

      min_size     = 1
      max_size     = 5
      desired_size = 2
    }
  }
  enable_cluster_creator_admin_permissions = true

}