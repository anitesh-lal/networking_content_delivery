# =============================================
#  Private Security Group
# =============================================

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
