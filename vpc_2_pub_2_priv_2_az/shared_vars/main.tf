output "vpc_cidr_range" {
  value = var.app_vpc_cidr
}
output "subnet_pub_1_range" {
  value = var.cidrs["public1"]
}
output "subnet_pub_2_range" {
  value = var.cidrs["public2"]
}
output "subnet_priv_1_range" {
  value = var.cidrs["private1"]
}
output "subnet_priv_2_range" {
  value = var.cidrs["private2"]
}
output "env_suffix" {
  value = local.env
}
output "app_prefix" {
  value = local.app
}
output "aws_region" {
  value = var.credentials["aws_region"]
}
output "aws_profile" {
  value = var.credentials["aws_profile"]
}

locals {
  env = terraform.workspace
  app = "AWX-App"
}

################################################################
variable "credentials" {
  type = map
  default = {
    aws_region  = "us-west-2"
    aws_profile = "pacificbreeze007"
  }
}

variable "app_vpc_cidr" {
  type    = string
  default = "172.50.0.0/16"

}
variable "cidrs" {
  type = map
  default = {
    "public1"  = "172.50.10.0/24"
    "public2"  = "172.50.14.0/24"
    "private1" = "172.50.18.0/24"
    "private2" = "172.50.22.0/24"
  }
}
################################################################
