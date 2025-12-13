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