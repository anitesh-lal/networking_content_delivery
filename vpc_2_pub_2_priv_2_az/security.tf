
#---------Deploying Public Security Group---------#

resource "aws_security_group" "app_vpc_pub_sg" {
  name        = "${local.app_name} Public-SG"
  description = "Allow Public Access to ${local.app_name} VPC"
  vpc_id      = aws_vpc.app_vpc.id

  ### SSH
  ingress {
    description = "SSH into VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ### HTTP
  ingress {
    description = "HTTP traffic into VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ### HTTPS
  ingress {
    description = "HTTPS traffic into VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Outbound access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name              = "${local.app_name}-VPC-PUB-SUB-SG"
    Service           = local.service_name
    Owner             = local.owner
    Environment       = local.environment
    terraform_managed = "true"
  }
}

#---------Deploying Private Security Group---------#

resource "aws_security_group" "app_vpc_priv_sg" {
  name        = "${local.app_name} Private-SG"
  description = "Allow Private Access to ${local.app_name} VPC"
  vpc_id      = aws_vpc.app_vpc.id

  ### From VPC - Internal Traffic Only
  ingress {
    description = "Allow inbound traffic from ${local.app_name} VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "Outbound access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name              = "${local.app_name}-VPC-PRIV-SUB-SG"
    Service           = local.service_name
    Owner             = local.owner
    Environment       = local.environment
    terraform_managed = "true"
  }
}
