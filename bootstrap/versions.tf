terraform {
  # use_lockfile (S3 native state locking) needs Terraform 1.10 or later.
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "aws" {
  region = var.region

  # Applied to every taggable resource. Azure equivalent: tags on the resource group
  # plus a policy that inherits them.
  default_tags {
    tags = {
      project    = "terraform-aws-modules"
      managed_by = "terraform"
      purpose    = "terraform-state"
    }
  }
}
