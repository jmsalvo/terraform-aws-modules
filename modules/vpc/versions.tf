terraform {
  required_version = ">= 1.10"

  # A reusable module declares which providers it needs but never configures them.
  # The caller sets the region and credentials. Same convention as terraform-azure-modules.
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
