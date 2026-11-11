variable "name" {
  description = "Name prefix for the VPC and its resources, for example \"lab\"."
  type        = string
}

variable "cidr_block" {
  description = "IPv4 address space for the VPC (Azure: the VNet address space)."
  type        = string
  default     = "10.20.0.0/16"

  validation {
    condition     = can(cidrhost(var.cidr_block, 0))
    error_message = "cidr_block must be a valid IPv4 CIDR, for example 10.20.0.0/16."
  }
}

variable "azs" {
  description = "Availability zones to spread subnets across. An AWS subnet lives in exactly one AZ (an Azure subnet spans the whole region)."
  type        = list(string)

  validation {
    condition     = length(var.azs) >= 1
    error_message = "Provide at least one availability zone."
  }
}

variable "public_subnet_cidrs" {
  description = "One CIDR per AZ, in the same order as azs. Public subnets have a route to the internet gateway."
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_cidrs) == length(var.azs) && alltrue([for c in var.public_subnet_cidrs : can(cidrhost(c, 0))])
    error_message = "public_subnet_cidrs must hold one valid CIDR per availability zone."
  }
}

variable "private_subnet_cidrs" {
  description = "One CIDR per AZ, in the same order as azs. Private subnets have no route to the internet."
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_cidrs) == length(var.azs) && alltrue([for c in var.private_subnet_cidrs : can(cidrhost(c, 0))])
    error_message = "private_subnet_cidrs must hold one valid CIDR per availability zone."
  }
}

variable "enable_s3_gateway_endpoint" {
  description = "Create a free S3 gateway endpoint so traffic to S3 stays on the AWS network (Azure: a service endpoint). Interface endpoints and NAT gateways are intentionally not created (hourly cost)."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Extra tags merged onto every resource."
  type        = map(string)
  default     = {}
}
