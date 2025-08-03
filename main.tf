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
  instance_tenancy     = var.vpc_instance_tenancy

  # IPv6 Configuration
  ipv6_cidr_block                                   = var.vpc_ipv6_cidr_block
  ipv6_cidr_block_network_border_group             = var.vpc_ipv6_cidr_block_network_border_group
  assign_generated_ipv6_cidr_block                 = var.vpc_assign_generated_ipv6_cidr_block
  enable_network_address_usage_metrics             = var.vpc_enable_network_address_usage_metrics

  tags = merge(
    var.common_tags,
    var.vpc_tags,
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

  # IPv6 Configuration
  ipv6_cidr_block                      = length(var.private_subnet_ipv6_cidr_blocks) > count.index ? var.private_subnet_ipv6_cidr_blocks[count.index] : null
  assign_ipv6_address_on_creation      = var.private_subnet_assign_ipv6_address_on_creation
  outpost_arn                          = length(var.private_subnet_outpost_arns) > count.index ? var.private_subnet_outpost_arns[count.index] : null

  tags = merge(
    var.common_tags,
    var.private_subnet_tags,
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

  # IPv6 Configuration
  ipv6_cidr_block                      = length(var.public_subnet_ipv6_cidr_blocks) > count.index ? var.public_subnet_ipv6_cidr_blocks[count.index] : null
  assign_ipv6_address_on_creation      = var.public_subnet_assign_ipv6_address_on_creation
  outpost_arn                          = length(var.public_subnet_outpost_arns) > count.index ? var.public_subnet_outpost_arns[count.index] : null

  tags = merge(
    var.common_tags,
    var.public_subnet_tags,
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
    var.internet_gateway_tags,
    {
      Name = "${var.name_prefix}-igw"
    }
  )
}

resource "aws_eip" "nat" {
  count = var.create_vpc && var.create_nat_gateways ? length(var.public_subnet_cidrs) : 0

  domain = var.eip_domain

  # Enhanced EIP Configuration
  network_border_group = var.eip_network_border_group
  public_ipv4_pool     = var.eip_public_ipv4_pool

  tags = merge(
    var.common_tags,
    var.eip_tags,
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

  # Enhanced NAT Gateway Configuration
  connectivity_type = var.nat_gateway_connectivity_type
  private_ip        = length(var.nat_gateway_private_ips) > count.index ? var.nat_gateway_private_ips[count.index] : null

  tags = merge(
    var.common_tags,
    var.nat_gateway_tags,
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

  # Additional public routes
  dynamic "route" {
    for_each = var.additional_public_routes
    content {
      cidr_block                = route.value.cidr_block
      gateway_id                = lookup(route.value, "gateway_id", null)
      nat_gateway_id            = lookup(route.value, "nat_gateway_id", null)
      network_interface_id      = lookup(route.value, "network_interface_id", null)
      transit_gateway_id        = lookup(route.value, "transit_gateway_id", null)
      vpc_endpoint_id           = lookup(route.value, "vpc_endpoint_id", null)
      vpc_peering_connection_id = lookup(route.value, "vpc_peering_connection_id", null)
      egress_only_gateway_id    = lookup(route.value, "egress_only_gateway_id", null)
      local_gateway_id          = lookup(route.value, "local_gateway_id", null)
      carrier_gateway_id        = lookup(route.value, "carrier_gateway_id", null)
      core_network_arn          = lookup(route.value, "core_network_arn", null)
    }
  }

  tags = merge(
    var.common_tags,
    var.route_table_tags,
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

  # Additional private routes
  dynamic "route" {
    for_each = var.additional_private_routes
    content {
      cidr_block                = route.value.cidr_block
      gateway_id                = lookup(route.value, "gateway_id", null)
      nat_gateway_id            = lookup(route.value, "nat_gateway_id", null)
      network_interface_id      = lookup(route.value, "network_interface_id", null)
      transit_gateway_id        = lookup(route.value, "transit_gateway_id", null)
      vpc_endpoint_id           = lookup(route.value, "vpc_endpoint_id", null)
      vpc_peering_connection_id = lookup(route.value, "vpc_peering_connection_id", null)
      egress_only_gateway_id    = lookup(route.value, "egress_only_gateway_id", null)
      local_gateway_id          = lookup(route.value, "local_gateway_id", null)
      carrier_gateway_id        = lookup(route.value, "carrier_gateway_id", null)
      core_network_arn          = lookup(route.value, "core_network_arn", null)
    }
  }

  tags = merge(
    var.common_tags,
    var.route_table_tags,
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
  type       = lookup(each.value, "type", "ipsec.1")

  tags = merge(
    var.common_tags,
    lookup(each.value, "tags", {}),
    {
      Name = "${var.name_prefix}-cgw-${each.key}"
    }
  )
}

resource "aws_vpn_gateway" "main" {
  count = var.create_vpn_gateway ? 1 : 0

  vpc_id = aws_vpc.main[0].id

  # Enhanced VPN Gateway Configuration
  amazon_side_asn = var.vpn_gateway_amazon_side_asn

  tags = merge(
    var.common_tags,
    var.vpn_gateway_tags,
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

  # Enhanced VPN Connection Configuration
  tunnel1_inside_ipv6_cidr = lookup(each.value, "tunnel1_inside_ipv6_cidr", null)
  tunnel2_inside_ipv6_cidr = lookup(each.value, "tunnel2_inside_ipv6_cidr", null)

  # Tunnel 1 Configuration
  tunnel1_preshared_key     = lookup(each.value, "tunnel1_preshared_key", null)
  tunnel1_dpd_timeout_action = lookup(each.value, "tunnel1_dpd_timeout_action", "clear")
  tunnel1_dpd_timeout_seconds = lookup(each.value, "tunnel1_dpd_timeout_seconds", 30)
  tunnel1_ike_versions      = lookup(each.value, "tunnel1_ike_versions", ["ikev2"])
  tunnel1_phase1_dh_group_numbers = lookup(each.value, "tunnel1_phase1_dh_group_numbers", [2, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24])
  tunnel1_phase1_encryption_algorithms = lookup(each.value, "tunnel1_phase1_encryption_algorithms", ["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"])
  tunnel1_phase1_integrity_algorithms = lookup(each.value, "tunnel1_phase1_integrity_algorithms", ["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"])
  tunnel1_phase2_dh_group_numbers = lookup(each.value, "tunnel1_phase2_dh_group_numbers", [2, 5, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24])
  tunnel1_phase2_encryption_algorithms = lookup(each.value, "tunnel1_phase2_encryption_algorithms", ["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"])
  tunnel1_phase2_integrity_algorithms = lookup(each.value, "tunnel1_phase2_integrity_algorithms", ["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"])
  tunnel1_rekey_fuzz_percentage = lookup(each.value, "tunnel1_rekey_fuzz_percentage", 100)
  tunnel1_rekey_margin_time_seconds = lookup(each.value, "tunnel1_rekey_margin_time_seconds", 540)
  tunnel1_replay_window_size = lookup(each.value, "tunnel1_replay_window_size", 1024)
  tunnel1_startup_action = lookup(each.value, "tunnel1_startup_action", "add")

  # Tunnel 2 Configuration
  tunnel2_preshared_key     = lookup(each.value, "tunnel2_preshared_key", null)
  tunnel2_dpd_timeout_action = lookup(each.value, "tunnel2_dpd_timeout_action", "clear")
  tunnel2_dpd_timeout_seconds = lookup(each.value, "tunnel2_dpd_timeout_seconds", 30)
  tunnel2_ike_versions      = lookup(each.value, "tunnel2_ike_versions", ["ikev2"])
  tunnel2_phase1_dh_group_numbers = lookup(each.value, "tunnel2_phase1_dh_group_numbers", [2, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24])
  tunnel2_phase1_encryption_algorithms = lookup(each.value, "tunnel2_phase1_encryption_algorithms", ["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"])
  tunnel2_phase1_integrity_algorithms = lookup(each.value, "tunnel2_phase1_integrity_algorithms", ["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"])
  tunnel2_phase2_dh_group_numbers = lookup(each.value, "tunnel2_phase2_dh_group_numbers", [2, 5, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24])
  tunnel2_phase2_encryption_algorithms = lookup(each.value, "tunnel2_phase2_encryption_algorithms", ["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"])
  tunnel2_phase2_integrity_algorithms = lookup(each.value, "tunnel2_phase2_integrity_algorithms", ["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"])
  tunnel2_rekey_fuzz_percentage = lookup(each.value, "tunnel2_rekey_fuzz_percentage", 100)
  tunnel2_rekey_margin_time_seconds = lookup(each.value, "tunnel2_rekey_margin_time_seconds", 540)
  tunnel2_replay_window_size = lookup(each.value, "tunnel2_replay_window_size", 1024)
  tunnel2_startup_action = lookup(each.value, "tunnel2_startup_action", "add")

  tags = merge(
    var.common_tags,
    lookup(each.value, "tags", {}),
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
  multicast_support               = var.transit_gateway_multicast_support

  tags = merge(
    var.common_tags,
    var.transit_gateway_tags,
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

  # Enhanced Transit Gateway VPC Attachment Configuration
  transit_gateway_default_route_table_association = var.transit_gateway_vpc_attachment_default_route_table_association
  transit_gateway_default_route_table_propagation = var.transit_gateway_vpc_attachment_default_route_table_propagation
  appliance_mode_support                          = var.transit_gateway_vpc_attachment_appliance_mode_support
  dns_support                                      = var.transit_gateway_vpc_attachment_dns_support
  ipv6_support                                     = var.transit_gateway_vpc_attachment_ipv6_support

  tags = merge(
    var.common_tags,
    var.transit_gateway_vpc_attachment_tags,
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

  dynamic "egress" {
    for_each = var.vpn_security_group_egress_rules
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
      description = egress.value.description
    }
  }

  tags = merge(
    var.common_tags,
    var.vpn_security_group_tags,
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
  kms_key_id        = var.vpn_log_kms_key_id

  tags = merge(
    var.common_tags,
    var.vpn_log_tags,
    {
      Name = "${var.name_prefix}-vpn-logs"
    }
  )
}

# =============================================================================
# CloudWatch Alarms
# =============================================================================

resource "aws_cloudwatch_metric_alarm" "main" {
  for_each = var.create_cloudwatch_alarms ? var.cloudwatch_alarms : {}

  alarm_name          = each.value.alarm_name
  comparison_operator = each.value.comparison_operator
  evaluation_periods  = each.value.evaluation_periods
  metric_name         = each.value.metric_name
  namespace           = each.value.namespace
  period              = each.value.period
  statistic           = each.value.statistic
  threshold           = each.value.threshold

  # Enhanced CloudWatch Alarm Configuration
  alarm_description   = lookup(each.value, "alarm_description", null)
  alarm_actions       = lookup(each.value, "alarm_actions", [])
  ok_actions          = lookup(each.value, "ok_actions", [])
  insufficient_data_actions = lookup(each.value, "insufficient_data_actions", [])
  treat_missing_data  = lookup(each.value, "treat_missing_data", "missing")
  unit                = lookup(each.value, "unit", null)
  extended_statistic  = lookup(each.value, "extended_statistic", null)
  datapoints_to_alarm = lookup(each.value, "datapoints_to_alarm", null)
  threshold_metric_id = lookup(each.value, "threshold_metric_id", null)

  dynamic "dimensions" {
    for_each = lookup(each.value, "dimensions", [])
    content {
      name  = dimensions.value.name
      value = dimensions.value.value
    }
  }

  dynamic "metric_query" {
    for_each = lookup(each.value, "metric_query", [])
    content {
      id          = metric_query.value.id
      expression  = lookup(metric_query.value, "expression", null)
      label       = lookup(metric_query.value, "label", null)
      return_data = lookup(metric_query.value, "return_data", true)
    }
  }

  tags = merge(
    var.common_tags,
    lookup(each.value, "tags", {}),
    {
      Name = "${var.name_prefix}-alarm-${each.key}"
    }
  )
}

# =============================================================================
# VPC Endpoints
# =============================================================================

resource "aws_vpc_endpoint" "main" {
  for_each = var.create_vpc_endpoints ? var.vpc_endpoints : {}

  vpc_id              = aws_vpc.main[0].id
  service_name        = each.value.service_name
  vpc_endpoint_type   = lookup(each.value, "vpc_endpoint_type", "Gateway")
  private_dns_enabled = lookup(each.value, "private_dns_enabled", true)

  # Enhanced VPC Endpoint Configuration
  subnet_ids         = lookup(each.value, "subnet_ids", [])
  security_group_ids = lookup(each.value, "security_group_ids", [])
  policy             = lookup(each.value, "policy", null)
  route_table_ids    = lookup(each.value, "route_table_ids", [])

  tags = merge(
    var.common_tags,
    lookup(each.value, "tags", {}),
    {
      Name = "${var.name_prefix}-endpoint-${each.key}"
    }
  )
}

# =============================================================================
# IAM Roles and Policies
# =============================================================================

resource "aws_iam_role" "vpn_monitoring" {
  count = var.create_vpn_monitoring_role ? 1 : 0

  name = "${var.name_prefix}-vpn-monitoring-role"

  # Enhanced IAM Role Configuration
  permissions_boundary = var.vpn_monitoring_role_permissions_boundary

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
    var.vpn_monitoring_role_tags,
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