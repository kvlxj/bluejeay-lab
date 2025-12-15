module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21"

  name                   = var.name
  kubernetes_version     = var.kubernetes_version
  endpoint_public_access = false

  enable_cluster_creator_admin_permissions = false

  access_entries = {
    # No need to define this user as this is the one that creates the cluster and the variable 'enable_cluster_creator_admin_permissions' is set to true
    kv = {
      user_name         = "kv"
      principal_arn     = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:user/kv.aws@jeay.io"
      kubernetes_groups = ["cluster-admin"]
    }
  }

  addons = {
    aws-ebs-csi-driver     = {}
    coredns                = {}
    eks-pod-identity-agent = { before_compute = true }
    kube-proxy             = {}
    vpc-cni                = { before_compute = true }
  }

  vpc_id                   = data.aws_vpc.this.id
  subnet_ids               = data.aws_subnets.private.ids
  control_plane_subnet_ids = data.aws_subnets.intra.ids




  eks_managed_node_groups = {
    default = {
      name       = "default"
      subnet_ids = slice(data.aws_subnets.private.ids, 0, 3)

      min_size     = 1
      max_size     = 3
      desired_size = 2

      ami_type            = "BOTTLEROCKET_x86_64"
      ami_release_version = "1.49.0-713f44ce"

      metadata_options = {
        http_endpoint = "enabled"
        http_tokens   = "required"
      }

      capacity_type        = "SPOT"
      force_update_version = true
      instance_types       = ["t3.small", "t3a.small"]
      disk_size            = 20
    }
    # default = {
    #   name       = "default"
    #   subnet_ids = [element(data.aws_subnets.private.ids, 0)]

    #   min_size     = 2
    #   max_size     = 3
    #   desired_size = 2

    #   ami_type            = "BOTTLEROCKET_x86_64"
    #   ami_release_version = "1.49.0-713f44ce"

    #   metadata_options = {
    #     http_endpoint = "enabled"
    #     http_tokens   = "required"
    #   }

    #   capacity_type        = "SPOT"
    #   force_update_version = true
    #   instance_types       = ["c7i.xlarge", "c7i-flex.xlarge", "c6i.xlarge", "t3a.xlarge", "c7i.2xlarge", "c7i-flex.2xlarge"]
    # }
  }
}
