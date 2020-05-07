provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

# =============================================
#  VPC
# =============================================

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

# =============================================
#  Internet Gateway (IGW)
# =============================================

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

# =============================================
#  Public Route Table (RTB)
# =============================================

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

# =============================================
#  Private Route Table (RTB)
# =============================================

resource "aws_route_table" "app_vpc_priv_rtb" {
  vpc_id = aws_vpc.app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.app_vpc_natgw_pub1.id
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.app_vpc_natgw_pub2.id
  }

  tags = {
    Name              = "${local.app_name}-VPC-PRIV-RTB"
    Service           = local.service_name
    Owner             = local.owner
    Environment       = local.environment
    terraform_managed = "true"
  }
}

# =============================================
#  Elastic IP for Public Subnet 1 (EIP-1)
# =============================================

resource "aws_eip" "app_vpc_eip_pub1" {
  vpc = true

  tags = {
    Name              = "${local.app_name}-VPC-EIP-PUB1"
    Service           = local.service_name
    Owner             = local.owner
    Environment       = local.environment
    terraform_managed = "true"
  }
}

# =============================================
#  Elastic IP for Public Subnet 2 (EIP-2)
# =============================================

resource "aws_eip" "app_vpc_eip_pub2" {
  vpc = true

  tags = {
    Name              = "${local.app_name}-VPC-EIP-PUB2"
    Service           = local.service_name
    Owner             = local.owner
    Environment       = local.environment
    terraform_managed = "true"
  }
}

# =============================================
#  NAT GATEWAY for Public Subnet 1 (NATGW-1)
# =============================================

resource "aws_nat_gateway" "app_vpc_natgw_pub1" {
  allocation_id = aws_eip.app_vpc_eip_pub1.id
  subnet_id     = aws_subnet.app_vpc_pub_sub1.id

  tags = {
    Name              = "${local.app_name}-VPC-NGW-PUB1-A"
    Service           = local.service_name
    Owner             = local.owner
    Environment       = local.environment
    terraform_managed = "true"
  }
}

# =============================================
#  NAT GATEWAY for Public Subnet 2 (NATGW-2)
# =============================================

resource "aws_nat_gateway" "app_vpc_natgw_pub2" {
  allocation_id = aws_eip.app_vpc_eip_pub2.id
  subnet_id     = aws_subnet.app_vpc_pub_sub2.id

  tags = {
    Name              = "${local.app_name}-VPC-NGW-PUB2-A"
    Service           = local.service_name
    Owner             = local.owner
    Environment       = local.environment
    terraform_managed = "true"
  }
}

##### Below Code can be expanded upon #####
##### Leveraging Two Availability Zones to achieve High Availability - Round Robin #####

# =============================================
#  Public Subnets
# =============================================

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

# =============================================
#  Private Subnets
# =============================================

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

# =============================================
#  Database Subnets
# =============================================


resource "aws_subnet" "rds1_subnet" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = var.cidrs["database1"]
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[0]

    tags = {
    Name              = "${local.app_name}-VPC-RDS1"
    Service           = local.service_name
    Owner             = local.owner
    Environment       = local.environment
    terraform_managed = "true"
  }
}

resource "aws_subnet" "rds2_subnet" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = var.cidrs["database2"]
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[1]

    tags = {
    Name              = "${local.app_name}-VPC-RDS2"
    Service           = local.service_name
    Owner             = local.owner
    Environment       = local.environment
    terraform_managed = "true"
  }
}

resource "aws_subnet" "rds3_subnet" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = var.cidrs["database3"]
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[2]

    tags = {
    Name              = "${local.app_name}-VPC-RDS3"
    Service           = local.service_name
    Owner             = local.owner
    Environment       = local.environment
    terraform_managed = "true"
  }
}

resource "aws_db_subnet_group" "rds_subnetgroup" {
  name = "awx_rds_subnetgroup"

  subnet_ids = [
    aws_subnet.rds1_subnet.id,
    aws_subnet.rds2_subnet.id,
    aws_subnet.rds3_subnet.id,
  ]
  tags = {
  Name              = "${local.app_name}-VPC-RDS-SNG"
  Service           = local.service_name
  Owner             = local.owner
  Environment       = local.environment
  terraform_managed = "true"
  }
}

# =============================================
#  Public Route Table Subnet Assosciation
# =============================================

resource "aws_route_table_association" "app_vpc_pub1_rtb_assoc" {
  subnet_id      = aws_subnet.app_vpc_pub_sub1.id
  route_table_id = aws_route_table.app_vpc_pub_rtb.id
}

resource "aws_route_table_association" "app_vpc_pub2_rtb_assoc" {
  subnet_id      = aws_subnet.app_vpc_pub_sub2.id
  route_table_id = aws_route_table.app_vpc_pub_rtb.id
}

# =============================================
#  Private Route Table Subnet Assosciation
# =============================================

resource "aws_route_table_association" "app_vpc_priv1_rtb_assoc" {
  subnet_id      = aws_subnet.app_vpc_priv_sub1.id
  route_table_id = aws_route_table.app_vpc_priv_rtb.id
}

resource "aws_route_table_association" "app_vpc_priv2_rtb_assoc" {
  subnet_id      = aws_subnet.app_vpc_priv_sub2.id
  route_table_id = aws_route_table.app_vpc_priv_rtb.id
}