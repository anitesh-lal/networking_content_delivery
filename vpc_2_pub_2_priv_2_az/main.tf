provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

#---------Creating the VPC---------#

resource "aws_vpc" "app_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name              = "${local.app_name}-VPC"
    Service           = local.service_name
    Owner             = local.owner
    Environment       = local.environment
    terraform_managed = "true"

  }
}

#---------Internet Gateway (IGW)---------#

resource "aws_internet_gateway" "app_vpc_igw" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name              = "${local.app_name}-VPC-IGW"
    Service           = local.service_name
    Owner             = local.owner
    Environment       = local.environment
    terraform_managed = "true"
  }
}

#---------Creating the Public Route Table (RTB)---------#

resource "aws_route_table" "app_vpc_pub_rtb" {
  vpc_id = aws_vpc.app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app_vpc_igw.id
  }

  tags = {
    Name              = "${local.app_name}-VPC-PUB-RTB"
    Service           = local.service_name
    Owner             = local.owner
    Environment       = local.environment
    terraform_managed = "true"
  }
}

#---------Creating the Private Route Table (RTB)---------#

resource "aws_route_table" "app_vpc_priv_rtb" {
  vpc_id = aws_vpc.app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.app_vpc_natgw.id
  }

  tags = {
    Name              = "${local.app_name}-VPC-PRIV-RTB"
    Service           = local.service_name
    Owner             = local.owner
    Environment       = local.environment
    terraform_managed = "true"
  }
}

#---------Allocating an Elastic IP---------#

resource "aws_eip" "app_vpc_natgw_eip_alloc" {
  vpc = true

  tags = {
    Name = "${local.app_name}-VPC-EIP"
  }
}

#---------Create the Nat Gateway---------#

resource "aws_nat_gateway" "app_vpc_natgw" {
  allocation_id = aws_eip.app_vpc_natgw_eip_alloc.id
  subnet_id     = aws_subnet.app_vpc_priv_sub1.id

  tags = {
    Name              = "${local.app_name}-VPC-NGW-A"
    Service           = local.service_name
    Owner             = local.owner
    Environment       = local.environment
    terraform_managed = "true"
  }
}

##### Below Code can be expanded upon #####
##### Leveraging Two Availability Zones to achieve High Availability - Round Robin #####

#---------Creating the Public Subnets---------#

resource "aws_subnet" "app_vpc_pub_sub1" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = var.cidrs["public1"]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name              = "${local.app_name}-VPC-PUB-SUB1"
    Service           = local.service_name
    Owner             = local.owner
    Environment       = local.environment
    terraform_managed = "true"
  }
}

resource "aws_subnet" "app_vpc_pub_sub2" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = var.cidrs["public2"]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[1]

  tags = {
    Name              = "${local.app_name}-VPC-PUB-SUB2"
    Service           = local.service_name
    Owner             = local.owner
    Environment       = local.environment
    terraform_managed = "true"
  }
}

#---------Creating the Private Subnets---------#

resource "aws_subnet" "app_vpc_priv_sub1" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = var.cidrs["private1"]
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name              = "${local.app_name}-VPC-PRIV-SUB1"
    Service           = local.service_name
    Owner             = local.owner
    Environment       = local.environment
    terraform_managed = "true"
  }
}

resource "aws_subnet" "app_vpc_priv_sub2" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = var.cidrs["private2"]
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[1]

  tags = {
    Name              = "${local.app_name}-VPC-PRIV-SUB2"
    Service           = local.service_name
    Owner             = local.owner
    Environment       = local.environment
    terraform_managed = "true"
  }
}

#---------Associating the Public Subnets to Public Route Table---------#

resource "aws_route_table_association" "app_vpc_pub1_rtb_assoc" {
  subnet_id      = aws_subnet.app_vpc_pub_sub1.id
  route_table_id = aws_route_table.app_vpc_pub_rtb.id
}

resource "aws_route_table_association" "app_vpc_pub2_rtb_assoc" {
  subnet_id      = aws_subnet.app_vpc_pub_sub2.id
  route_table_id = aws_route_table.app_vpc_pub_rtb.id
}

#---------Associating the Private Subnets to Private Route Table---------#

resource "aws_route_table_association" "app_vpc_priv1_rtb_assoc" {
  subnet_id      = aws_subnet.app_vpc_priv_sub1.id
  route_table_id = aws_route_table.app_vpc_priv_rtb.id
}

resource "aws_route_table_association" "app_vpc_priv2_rtb_assoc" {
  subnet_id      = aws_subnet.app_vpc_priv_sub2.id
  route_table_id = aws_route_table.app_vpc_priv_rtb.id
}
