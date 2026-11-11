data "aws_region" "current" {}

locals {
  # for_each keys are the AZ names, so each subnet has a stable identity.
  # (count would key by position: removing one AZ from the middle of the list would
  # shift every later subnet and force them to be destroyed and recreated.)
  public_subnets  = zipmap(var.azs, var.public_subnet_cidrs)
  private_subnets = zipmap(var.azs, var.private_subnet_cidrs)
}

# The VPC is the private network. Azure equivalent: a virtual network.
resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, { Name = var.name })
}

# Internet gateway: the explicit door between the VPC and the internet.
# Azure VNets get outbound internet by default, so there is no direct equivalent.
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, { Name = "${var.name}-igw" })
}

resource "aws_subnet" "public" {
  for_each = local.public_subnets

  vpc_id            = aws_vpc.this.id
  availability_zone = each.key
  cidr_block        = each.value

  # Do not hand out public IPs automatically; require an explicit choice.
  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    Name = "${var.name}-public-${each.key}"
    tier = "public"
  })
}

resource "aws_subnet" "private" {
  for_each = local.private_subnets

  vpc_id            = aws_vpc.this.id
  availability_zone = each.key
  cidr_block        = each.value

  tags = merge(var.tags, {
    Name = "${var.name}-private-${each.key}"
    tier = "private"
  })
}

# A subnet is "public" in AWS only because its route table sends 0.0.0.0/0 to an
# internet gateway. Nothing else makes it public.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, { Name = "${var.name}-public" })
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# The private route table has only the implicit local route (traffic inside the VPC).
# No route to the internet: this is what makes the subnets private.
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, { Name = "${var.name}-private" })
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

# S3 gateway endpoint: adds a route (via a prefix list) so S3 traffic stays on the AWS
# network. Gateway endpoints are free. Azure equivalent: a service endpoint.
resource "aws_vpc_endpoint" "s3" {
  count = var.enable_s3_gateway_endpoint ? 1 : 0

  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${data.aws_region.current.region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    aws_route_table.public.id,
    aws_route_table.private.id,
  ]

  tags = merge(var.tags, { Name = "${var.name}-s3" })
}

# Every VPC comes with a default security group that allows all traffic between its
# members. Managing it with no rules empties it, so nothing can use it by accident.
resource "aws_default_security_group" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, { Name = "${var.name}-default-no-rules" })
}
