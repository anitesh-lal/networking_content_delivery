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
#  TRANSIT GATEWAY
# =============================================

resource "aws_ec2_transit_gateway" "transit_gateway" {
  description = "${local.app_name} Transit Gateway"
  tags = {
    Name              = "${local.app_name}-TGW"
    Service           = local.service_name
    Owner             = local.owner
    Environment       = local.environment
    terraform_managed = "true"

  }
}

# =============================================
#  TRANSIT GATEWAY TO VPC ATTACHMENT
# =============================================

resource "aws_ec2_transit_gateway_vpc_attachment" "tg_to_vpc" {
  subnet_ids = [aws_subnet.app_vpc_priv_sub1.id,
    aws_subnet.app_vpc_priv_sub2.id,
    aws_subnet.app_vpc_priv_sub3.id,
    aws_subnet.app_vpc_priv_sub4.id,
    aws_subnet.app_vpc_priv_sub5.id,
    aws_subnet.app_vpc_priv_sub6.id,
    aws_subnet.app_vpc_priv_sub7.id,
  aws_subnet.app_vpc_priv_sub8.id]
  transit_gateway_id = aws_ec2_transit_gateway.transit_gateway.id
  vpc_id             = aws_vpc.app_vpc.id
}

# =============================================
#  TRANSIT GATEWAY ROUTE TABLE
# =============================================

resource "aws_ec2_transit_gateway_route_table" "tg_rtb" {
  transit_gateway_id = aws_ec2_transit_gateway.transit_gateway.id
}

# =============================================
#  TRANSIT GATEWAY ROUTES
# =============================================

resource "aws_ec2_transit_gateway_route" "tg_routes" {
  destination_cidr_block         = var.datacenter
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tg_to_vpc.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.transit_gateway.association_default_route_table_id
}

# =============================================
#  TRANSIT GATEWAY ROUTE TABLE ASSOCIATION
# =============================================

resource "aws_ec2_transit_gateway_route_table_association" "tg_rtb_assoc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tg_to_vpc.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tg_rtb.id
}

# =============================================
#  TRANSIT GATEWAY ROUTE TABLE PROPAGATION
# =============================================

resource "aws_ec2_transit_gateway_route_table_propagation" "tg_rtb_prop" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tg_to_vpc.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tg_rtb.id
}

# =============================================
#  CUSTOMER GATEWAY
# =============================================

resource "aws_customer_gateway" "customer_gateway" {
  bgp_asn    = 65000
  ip_address = "127.0.0.1" // --public-ip <value>
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
  transit_gateway_id  = aws_ec2_transit_gateway.transit_gateway.id // AWS side of information
  customer_gateway_id = aws_customer_gateway.customer_gateway.id   // Our network side of information
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

  #route {
  #  cidr_block = var.localip
  #  gateway_id = aws_ec2_transit_gateway.transit_gateway.id
  #}

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