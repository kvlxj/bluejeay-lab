module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21"

  name                   = var.name
  kubernetes_version     = var.kubernetes_version
  endpoint_public_access = false

  addons = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni = {
      before_compute = true
    }
    coredns = {
      most_recent = true
      configuration_values = jsonencode(
        {
          "autoScaling" : {
            "enabled" : true,
            "minReplicas" : 2,
            "maxReplicas" : 4
          }
          tolerations = [
            {
              operator = "Exists"
            }
          ]
        }
      )
    }

    eks-pod-identity-agent = {
      most_recent = true
    }
  }

  enable_cluster_creator_admin_permissions = true

  vpc_id                   = data.aws_vpc.this.id
  subnet_ids               = data.aws_subnets.private.ids
  control_plane_subnet_ids = data.aws_subnets.intra.ids

  eks_managed_node_groups = {
    default = {
      name = "default"
      # Use a single subnet for costs reasons
      subnet_ids = [element(data.aws_subnets.private.ids, 0)]

      min_size     = 2
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
      instance_types       = ["c7i.xlarge", "c7i-flex.xlarge", "c6i.xlarge", "t3a.xlarge", "c7i.2xlarge", "c7i-flex.2xlarge"]
    }
  }
}