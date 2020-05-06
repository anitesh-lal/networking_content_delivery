# =============================================
# General
# =============================================

variable "aws_region" {
  type = string
}

variable "aws_profile" {
  type = string
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
}

# =============================================
# APP Specific
# =============================================

locals {
  app_name     = "Shared-Services"
  service_name = "VPC Supernet for Shared Services"
  owner        = "Infrastructure Team"
  environment  = "Production"
  region       = data.aws_region.current.name
  account_id   = data.aws_caller_identity.current.account_id
}

locals {
  common_tags = {
    Application       = local.app_name
    Service           = local.service_name
    Owner             = local.owner
    Environment       = local.environment
    terraform_managed = "true"

  }
}

# =============================================
# NETWORKING Specific
# =============================================

variable "vpc_cidr" {
  description = "VPC IP block"
  type        = string
}
variable "cidrs" {
  type = map
}
variable "localip" {
  type = string
}
variable "datacenter" {
  type = string
}