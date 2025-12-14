variable "name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = "bluejeay-lab-eks"
}

variable "kubernetes_version" {
  description = "The Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.34"
}

variable "tags" {
  description = "A map of tags to assign to the VPC and its components"
  type        = map(string)
  default = {
    "app:env"  = "lab"
    "app:name" = "bluejeay"
  }
}
