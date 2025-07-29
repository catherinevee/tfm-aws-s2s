# =============================================================================
# AWS Site-to-Site Connectivity Module
# =============================================================================
# This module provides comprehensive connectivity solutions between on-premises
# networks and AWS Cloud, including VPN, Direct Connect, and Transit Gateway options.

# =============================================================================
# Data Sources
# =============================================================================

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

# =============================================================================
# VPC and Networking Resources
# =============================================================================

resource "aws_vpc" "main" {
  count = var.create_vpc ? 1 : 0

  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(
    var.common_tags,
    {
      Name = "${var.name_prefix}-vpc"
    }
  )
}

resource "aws_vpc_ipv4_cidr_block_association" "secondary_cidrs" {
  for_each = toset(var.vpc_secondary_cidr_blocks)

  vpc_id     = aws_vpc.main[0].id
  cidr_block = each.value
}

resource "aws_subnet" "private" {
  count = var.create_vpc ? length(var.private_subnet_cidrs) : 0

  vpc_id                  = aws_vpc.main[0].id
  cidr_block              = var.private_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]
  map_public_ip_on_launch = false

  tags = merge(
    var.common_tags,
    {
      Name = "${var.name_prefix}-private-subnet-${count.index + 1}"
      Tier = "Private"
    }
  )
}

resource "aws_subnet" "public" {
  count = var.create_vpc ? length(var.public_subnet_cidrs) : 0

  vpc_id                  = aws_vpc.main[0].id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge(
    var.common_tags,
    {
      Name = "${var.name_prefix}-public-subnet-${count.index + 1}"
      Tier = "Public"
    }
  )
}

resource "aws_internet_gateway" "main" {
  count = var.create_vpc && var.create_internet_gateway ? 1 : 0

  vpc_id = aws_vpc.main[0].id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.name_prefix}-igw"
    }
  )
}

resource "aws_eip" "nat" {
  count = var.create_vpc && var.create_nat_gateways ? length(var.public_subnet_cidrs) : 0

  domain = "vpc"

  tags = merge(
    var.common_tags,
    {
      Name = "${var.name_prefix}-nat-eip-${count.index + 1}"
    }
  )

  depends_on = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "main" {
  count = var.create_vpc && var.create_nat_gateways ? length(var.public_subnet_cidrs) : 0

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.name_prefix}-nat-gateway-${count.index + 1}"
    }
  )

  depends_on = [aws_internet_gateway.main]
}

# =============================================================================
# Route Tables
# =============================================================================

resource "aws_route_table" "public" {
  count = var.create_vpc ? 1 : 0

  vpc_id = aws_vpc.main[0].id

  dynamic "route" {
    for_each = var.create_internet_gateway ? [1] : []
    content {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.main[0].id
    }
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.name_prefix}-public-rt"
    }
  )
}

resource "aws_route_table" "private" {
  count = var.create_vpc && var.create_nat_gateways ? length(var.private_subnet_cidrs) : 0

  vpc_id = aws_vpc.main[0].id

  dynamic "route" {
    for_each = var.create_nat_gateways ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.main[count.index].id
    }
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.name_prefix}-private-rt-${count.index + 1}"
    }
  )
}

resource "aws_route_table_association" "public" {
  count = var.create_vpc ? length(var.public_subnet_cidrs) : 0

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
}

resource "aws_route_table_association" "private" {
  count = var.create_vpc ? length(var.private_subnet_cidrs) : 0

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = var.create_nat_gateways ? aws_route_table.private[count.index].id : aws_route_table.public[0].id
}

# =============================================================================
# VPN Connectivity
# =============================================================================

resource "aws_customer_gateway" "main" {
  for_each = var.customer_gateways

  bgp_asn    = each.value.bgp_asn
  ip_address = each.value.ip_address
  type       = "ipsec.1"

  tags = merge(
    var.common_tags,
    {
      Name = "${var.name_prefix}-cgw-${each.key}"
    }
  )
}

resource "aws_vpn_gateway" "main" {
  count = var.create_vpn_gateway ? 1 : 0

  vpc_id = aws_vpc.main[0].id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.name_prefix}-vpn-gateway"
    }
  )
}

resource "aws_vpn_connection" "main" {
  for_each = var.vpn_connections

  vpn_gateway_id      = aws_vpn_gateway.main[0].id
  customer_gateway_id = aws_customer_gateway.main[each.value.customer_gateway_key].id
  type                = "ipsec.1"
  static_routes_only  = each.value.static_routes_only

  tunnel1_inside_ipv6_cidr = each.value.tunnel1_inside_ipv6_cidr
  tunnel2_inside_ipv6_cidr = each.value.tunnel2_inside_ipv6_cidr

  tags = merge(
    var.common_tags,
    {
      Name = "${var.name_prefix}-vpn-${each.key}"
    }
  )
}

resource "aws_vpn_connection_route" "main" {
  for_each = var.vpn_routes

  destination_cidr_block = each.value.destination_cidr_block
  vpn_connection_id      = aws_vpn_connection.main[each.value.vpn_connection_key].id
}

# =============================================================================
# Direct Connect
# =============================================================================

resource "aws_dx_gateway" "main" {
  count = var.create_direct_connect_gateway ? 1 : 0

  name            = "${var.name_prefix}-dx-gateway"
  amazon_side_asn = var.dx_gateway_amazon_side_asn
}

resource "aws_dx_gateway_association" "main" {
  count = var.create_direct_connect_gateway && var.create_vpc ? 1 : 0

  dx_gateway_id         = aws_dx_gateway.main[0].id
  associated_gateway_id = aws_vpn_gateway.main[0].id

  allowed_prefixes = var.dx_allowed_prefixes
}

# =============================================================================
# Transit Gateway
# =============================================================================

resource "aws_ec2_transit_gateway" "main" {
  count = var.create_transit_gateway ? 1 : 0

  description                     = "Transit Gateway for ${var.name_prefix}"
  amazon_side_asn                 = var.transit_gateway_amazon_side_asn
  auto_accept_shared_attachments  = var.transit_gateway_auto_accept_shared_attachments
  default_route_table_association = var.transit_gateway_default_route_table_association
  default_route_table_propagation = var.transit_gateway_default_route_table_propagation
  dns_support                     = var.transit_gateway_dns_support
  vpn_ecmp_support                = var.transit_gateway_vpn_ecmp_support

  tags = merge(
    var.common_tags,
    {
      Name = "${var.name_prefix}-transit-gateway"
    }
  )
}

resource "aws_ec2_transit_gateway_vpc_attachment" "main" {
  count = var.create_transit_gateway && var.create_vpc ? 1 : 0

  subnet_ids         = aws_subnet.private[*].id
  transit_gateway_id = aws_ec2_transit_gateway.main[0].id
  vpc_id             = aws_vpc.main[0].id

  transit_gateway_default_route_table_association = var.transit_gateway_vpc_attachment_default_route_table_association
  transit_gateway_default_route_table_propagation = var.transit_gateway_vpc_attachment_default_route_table_propagation

  tags = merge(
    var.common_tags,
    {
      Name = "${var.name_prefix}-tgw-vpc-attachment"
    }
  )
}

# =============================================================================
# Security Groups
# =============================================================================

resource "aws_security_group" "vpn" {
  count = var.create_vpn_security_group ? 1 : 0

  name_prefix = "${var.name_prefix}-vpn-sg-"
  vpc_id      = aws_vpc.main[0].id

  dynamic "ingress" {
    for_each = var.vpn_security_group_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.name_prefix}-vpn-security-group"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# =============================================================================
# CloudWatch Logs
# =============================================================================

resource "aws_cloudwatch_log_group" "vpn" {
  count = var.create_vpn_logs ? 1 : 0

  name              = "/aws/vpn/${var.name_prefix}"
  retention_in_days = var.vpn_log_retention_days

  tags = merge(
    var.common_tags,
    {
      Name = "${var.name_prefix}-vpn-logs"
    }
  )
}

# =============================================================================
# IAM Roles and Policies
# =============================================================================

resource "aws_iam_role" "vpn_monitoring" {
  count = var.create_vpn_monitoring_role ? 1 : 0

  name = "${var.name_prefix}-vpn-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.common_tags,
    {
      Name = "${var.name_prefix}-vpn-monitoring-role"
    }
  )
}

resource "aws_iam_role_policy" "vpn_monitoring" {
  count = var.create_vpn_monitoring_role ? 1 : 0

  name = "${var.name_prefix}-vpn-monitoring-policy"
  role = aws_iam_role.vpn_monitoring[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeVpnConnections",
          "ec2:DescribeVpnGateways",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
} 