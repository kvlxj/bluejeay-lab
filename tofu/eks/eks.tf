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

  # Allow control plane to reach node/pod ports for API server service proxy feature
  node_security_group_additional_rules = {
    ingress_cluster_to_node_all_ports = {
      description                   = "Cluster API to node groups (for API server service proxy)"
      protocol                      = "tcp"
      from_port                     = 1025
      to_port                       = 65535
      type                          = "ingress"
      source_cluster_security_group = true
    }
  }

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

  tags = {
    "karpenter.sh/discovery" = var.name
  }

  // For the load balancer to work refer to https://github.com/opentofu-aws-modules/opentofu-aws-eks/blob/master/docs/faq.md
  node_security_group_tags = {
    "kubernetes.io/cluster/${var.name}" = null
  }
}