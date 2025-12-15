terraform {
  backend "s3" {
    bucket       = "bluejeay-tf-states"
    key          = "terraform/eks/terraform.tfstate"
    region       = "eu-west-3"
    encrypt      = true
    use_lockfile = true
  }
}
