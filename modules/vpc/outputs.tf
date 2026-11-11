output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.this.id
}

output "vpc_cidr_block" {
  description = "Address space of the VPC."
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "Public subnet IDs, keyed by availability zone."
  value       = { for az, s in aws_subnet.public : az => s.id }
}

output "private_subnet_ids" {
  description = "Private subnet IDs, keyed by availability zone."
  value       = { for az, s in aws_subnet.private : az => s.id }
}

output "public_route_table_id" {
  description = "ID of the public route table."
  value       = aws_route_table.public.id
}

output "private_route_table_id" {
  description = "ID of the private route table."
  value       = aws_route_table.private.id
}

output "s3_gateway_endpoint_id" {
  description = "ID of the S3 gateway endpoint, or null if disabled."
  value       = one(aws_vpc_endpoint.s3[*].id)
}
