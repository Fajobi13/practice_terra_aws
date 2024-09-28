
provider "aws" {
  region  = "eu-west-2"
  profile = "default"
}

variable "vpc_cidr_block" {}
variable "private_subnet_cidr_blocks" {}
variable "public_subnet_cidr_blocks" {}

data "aws_availability_zones" "azs" {}


module "dlick-vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.13.0"

  name = "dlick-vpc"
  cidr = var.vpc_cidr_block
  #create one private and one public subnet in each az ### as best practice
  private_subnets = var.private_subnet_cidr_blocks
  public_subnets  = var.public_subnet_cidr_blocks
  azs             = data.aws_availability_zones.azs.names #all available azs, which is 3 in my region at this time

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  # tagsrequired for controllers to identify the resources
  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = 1
  }
}

