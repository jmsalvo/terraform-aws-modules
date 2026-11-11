variable "region" {
  description = "AWS region for the state bucket."
  type        = string
  default     = "us-east-2"
}

variable "name_prefix" {
  description = "Prefix for the state bucket name. A random suffix is added because S3 bucket names are globally unique."
  type        = string
  default     = "tfstate"
}

variable "force_destroy" {
  description = "Allow terraform destroy to delete the bucket even if it still holds state objects. Leave false except when tearing the lab down."
  type        = bool
  default     = false
}
