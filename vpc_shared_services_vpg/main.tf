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
#  VPN GATEWAY
# =============================================

resource "aws_vpn_gateway" "vpn_gateway" {
  vpc_id            = aws_vpc.app_vpc.id
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name              = "${local.app_name}-VPN-GW"
    Service           = local.service_name
    Owner             = local.owner
    Environment       = local.environment
    terraform_managed = "true"

  }
}

# =============================================
#  CUSTOMER GATEWAY
# =============================================

resource "aws_customer_gateway" "customer_gateway" {
  bgp_asn    = 65000
  ip_address = "127.0.0.1" // This static IPaddr needs to come after device or software installation on our datacenter/network.
  type       = "ipsec.1"

  tags = {
    Name              = "${local.app_name}-main-customer-gateway"
    Service           = local.service_name
    Owner             = local.owner
    Environment       = local.environment
    terraform_managed = "true"
  }
}

# =============================================
#  SITE-TO-SITE VPN CONNECTION
# =============================================

resource "aws_vpn_connection" "main" {
  vpn_gateway_id      = aws_vpn_gateway.vpn_gateway.id           // AWS side of information
  customer_gateway_id = aws_customer_gateway.customer_gateway.id // Our network side of information
  type                = "ipsec.1"
  static_routes_only  = true
  #tunnel1_inside_cidr = 
  #tunnel2_inside_cidr = 
  #tunnel1_preshared_key = 
  #tunnel2_preshared_key =
}

# =============================================
#  VPN CONNECTION ROUTE
# =============================================

resource "aws_vpn_connection_route" "datacenter" {
  destination_cidr_block = var.datacenter // IPaddr of our datacenter/network.
  vpn_connection_id      = aws_vpn_connection.main.id
}

# =============================================
#  Private Route Table (RTB)
# =============================================

resource "aws_default_route_table" "app_vpc_priv_rtb" {
  default_route_table_id = aws_vpc.app_vpc.default_route_table_id

  route {
    cidr_block = var.localip
    gateway_id = aws_vpn_gateway.vpn_gateway.id
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
#  Private Subnets
# =============================================

resource "aws_subnet" "app_vpc_priv_sub1" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = var.cidrs["content_storage_subnet_az_1"]
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
  cidr_block              = var.cidrs["content_storage_subnet_az_2"]
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

resource "aws_subnet" "app_vpc_priv_sub3" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = var.cidrs["database_subnet_az_1"]
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name              = "${local.app_name}-VPC-PRIV-SUB3"
    Service           = local.service_name
    Owner             = local.owner
    Environment       = local.environment
    terraform_managed = "true"
  }
}

resource "aws_subnet" "app_vpc_priv_sub4" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = var.cidrs["database_subnet_az_2"]
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[1]

  tags = {
    Name              = "${local.app_name}-VPC-PRIV-SUB4"
    Service           = local.service_name
    Owner             = local.owner
    Environment       = local.environment
    terraform_managed = "true"
  }
}

resource "aws_subnet" "app_vpc_priv_sub5" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = var.cidrs["application_services_subnet_az_1"]
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name              = "${local.app_name}-VPC-PRIV-SUB5"
    Service           = local.service_name
    Owner             = local.owner
    Environment       = local.environment
    terraform_managed = "true"
  }
}

resource "aws_subnet" "app_vpc_priv_sub6" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = var.cidrs["application_services_subnet_az_2"]
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[1]

  tags = {
    Name              = "${local.app_name}-VPC-PRIV-SUB6"
    Service           = local.service_name
    Owner             = local.owner
    Environment       = local.environment
    terraform_managed = "true"
  }
}

resource "aws_subnet" "app_vpc_priv_sub7" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = var.cidrs["monitor_management_subnet_az_1"]
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name              = "${local.app_name}-VPC-PRIV-SUB7"
    Service           = local.service_name
    Owner             = local.owner
    Environment       = local.environment
    terraform_managed = "true"
  }
}

resource "aws_subnet" "app_vpc_priv_sub8" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = var.cidrs["monitor_management_subnet_az_2"]
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[1]

  tags = {
    Name              = "${local.app_name}-VPC-PRIV-SUB8"
    Service           = local.service_name
    Owner             = local.owner
    Environment       = local.environment
    terraform_managed = "true"
  }
}

# =============================================
#  Private Route Table Subnet Assosciation
# =============================================

resource "aws_route_table_association" "app_vpc_priv1_rtb_assoc" {
  subnet_id      = aws_subnet.app_vpc_priv_sub1.id
  route_table_id = aws_vpc.app_vpc.default_route_table_id
}

resource "aws_route_table_association" "app_vpc_priv2_rtb_assoc" {
  subnet_id      = aws_subnet.app_vpc_priv_sub2.id
  route_table_id = aws_vpc.app_vpc.default_route_table_id
}

resource "aws_route_table_association" "app_vpc_priv3_rtb_assoc" {
  subnet_id      = aws_subnet.app_vpc_priv_sub3.id
  route_table_id = aws_vpc.app_vpc.default_route_table_id
}

resource "aws_route_table_association" "app_vpc_priv4_rtb_assoc" {
  subnet_id      = aws_subnet.app_vpc_priv_sub4.id
  route_table_id = aws_vpc.app_vpc.default_route_table_id
}

resource "aws_route_table_association" "app_vpc_priv5_rtb_assoc" {
  subnet_id      = aws_subnet.app_vpc_priv_sub5.id
  route_table_id = aws_vpc.app_vpc.default_route_table_id
}

resource "aws_route_table_association" "app_vpc_priv6_rtb_assoc" {
  subnet_id      = aws_subnet.app_vpc_priv_sub6.id
  route_table_id = aws_vpc.app_vpc.default_route_table_id
}

resource "aws_route_table_association" "app_vpc_priv7_rtb_assoc" {
  subnet_id      = aws_subnet.app_vpc_priv_sub7.id
  route_table_id = aws_vpc.app_vpc.default_route_table_id
}

resource "aws_route_table_association" "app_vpc_priv8_rtb_assoc" {
  subnet_id      = aws_subnet.app_vpc_priv_sub8.id
  route_table_id = aws_vpc.app_vpc.default_route_table_id
}