data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = ["bluejeay-lab-vpc"]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "tag:kubernetes.io/role/internal-elb"
    values = ["1"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }
}

data "aws_subnets" "intra" {
  filter {
    name   = "tag:app:subnet-type"
    values = ["intra"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }
}
