##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  region = var.region
  assume_role {
    role_arn = "arn:aws:iam::158381789820:role/OrganizationAccountAccessRole"
  }
}

##################################################################################
# DATA
##################################################################################

data "aws_availability_zones" "available" {}

data "aws_caller_identity" "destination" {
}

##################################################################################
# RESOURCES
##################################################################################
locals {
  common_tags = {
    BillingCode = var.billing_code
  }
}

module "main" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = var.prefix
  cidr = var.cidr_block

  azs                     = slice(data.aws_availability_zones.available.names, 0, length(var.public_subnets))
  public_subnets          = [for k, v in var.public_subnets : v]
  public_subnet_names     = [for k, v in var.public_subnets : "${var.prefix}-${k}"]
  enable_dns_hostnames    = true
  public_subnet_suffix    = ""
  public_route_table_tags = { Name = "${var.prefix}-public" }
  map_public_ip_on_launch = true

  enable_nat_gateway = false

  tags = local.common_tags
}