terraform {
  backend "s3" {
    bucket  = "bluejeay-tf-states"
    key     = "terraform/vpc/terraform.tfstate"
    region  = "eu-west-3"
    encrypt = true
  }
}
