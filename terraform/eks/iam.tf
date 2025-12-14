module "aws_ebs_csi_pod_identity" {
  source = "terraform-aws-modules/eks-pod-identity/aws"

  name = "${var.name}aws-ebs-csi"

  attach_aws_ebs_csi_policy = true

  associations = {
    (var.name) = {
      cluster_name    = module.eks.cluster_name
      namespace       = "kube-system"
      service_account = "ebs-csi-controller-sa"
    }
  }
}

module "aws_vpc_cni_ipv4_pod_identity" {
  source = "terraform-aws-modules/eks-pod-identity/aws"

  name = "${var.name}-aws-vpc-cni-ipv4"

  attach_aws_vpc_cni_policy = true
  aws_vpc_cni_enable_ipv4   = true

  associations = {
    (var.name) = {
      cluster_name    = module.eks.cluster_name
      namespace       = "kube-system"
      service_account = "aws-node"
    }
  }
}

module "aws_lb_controller_pod_identity" {
  source = "terraform-aws-modules/eks-pod-identity/aws"

  name = "${var.name}-aws-lb-controller"

  attach_aws_lb_controller_policy = true

  associations = {
    (var.name) = {
      cluster_name    = module.eks.cluster_name
      namespace       = "kube-system"
      service_account = "aws-load-balancer-controller-sa"
    }
  }
}
