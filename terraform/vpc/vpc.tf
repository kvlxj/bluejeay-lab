
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "bluejeay-lab-vpc"
  cidr = var.cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(var.cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(var.cidr, 8, k + 48)]
  intra_subnets   = [for k, v in local.azs : cidrsubnet(var.cidr, 8, k + 52)]

  enable_nat_gateway   = true
  enable_dns_hostnames = true
  single_nat_gateway   = true

  enable_flow_log                      = true
  create_flow_log_cloudwatch_iam_role  = true
  create_flow_log_cloudwatch_log_group = true

  public_subnet_tags = merge(var.tags, {
    "subnet-type"            = "public"
    "kubernetes.io/role/elb" = 1
  })

  private_subnet_tags = merge(var.tags, {
    "subnet-type"                     = "private"
    "kubernetes.io/role/internal-elb" = 1
  })

  intra_subnet_tags = merge(var.tags, {
    "subnet-type" = "intra"
  })

}
