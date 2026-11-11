terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # Remote state in the S3 bucket created by /bootstrap.
  # use_lockfile = native S3 locking (Azure equivalent: the blob lease).
  # Backend blocks cannot use variables, so the bucket name is written out. It contains
  # no account ID or secret.
  backend "s3" {
    bucket       = "tfstate-68ab2883"
    key          = "vpc-example/terraform.tfstate"
    region       = "us-east-2"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = "us-east-2"

  default_tags {
    tags = {
      project    = "terraform-aws-modules"
      managed_by = "terraform"
      purpose    = "vpc-example"
    }
  }
}

module "vpc" {
  source = "../.."

  name = "lab"

  azs                  = ["us-east-2a", "us-east-2b"]
  public_subnet_cidrs  = ["10.20.0.0/24", "10.20.1.0/24"]
  private_subnet_cidrs = ["10.20.10.0/24", "10.20.11.0/24"]
}
