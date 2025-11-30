terraform {
  backend "s3" {
    bucket  = "bluejeay-tf-states"
    key     = "tofu/vpc/opentofu.tfstate"
    region  = "eu-west-3"
    encrypt = true
  }
}