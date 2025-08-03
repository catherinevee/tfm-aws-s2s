# =============================================================================
# Outputs for AWS Site-to-Site Connectivity Module
# =============================================================================

# =============================================================================
# VPC Outputs
# =============================================================================

output "vpc_id" {
  description = "ID of the VPC"
  value       = var.create_vpc ? aws_vpc.main[0].id : null
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = var.create_vpc ? aws_vpc.main[0].cidr_block : null
}

output "vpc_arn" {
  description = "ARN of the VPC"
  value       = var.create_vpc ? aws_vpc.main[0].arn : null
}

output "vpc_ipv6_cidr_block" {
  description = "IPv6 CIDR block of the VPC"
  value       = var.create_vpc ? aws_vpc.main[0].ipv6_cidr_block : null
}

output "vpc_instance_tenancy" {
  description = "Instance tenancy of the VPC"
  value       = var.create_vpc ? aws_vpc.main[0].instance_tenancy : null
}

output "vpc_enable_dns_hostnames" {
  description = "Whether DNS hostnames are enabled in the VPC"
  value       = var.create_vpc ? aws_vpc.main[0].enable_dns_hostnames : null
}

output "vpc_enable_dns_support" {
  description = "Whether DNS support is enabled in the VPC"
  value       = var.create_vpc ? aws_vpc.main[0].enable_dns_support : null
}

# =============================================================================
# Subnet Outputs
# =============================================================================

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = var.create_vpc ? aws_subnet.private[*].id : []
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = var.create_vpc ? aws_subnet.public[*].id : []
}

output "private_subnet_cidr_blocks" {
  description = "CIDR blocks of the private subnets"
  value       = var.create_vpc ? aws_subnet.private[*].cidr_block : []
}

output "public_subnet_cidr_blocks" {
  description = "CIDR blocks of the public subnets"
  value       = var.create_vpc ? aws_subnet.public[*].cidr_block : []
}

output "private_subnet_ipv6_cidr_blocks" {
  description = "IPv6 CIDR blocks of the private subnets"
  value       = var.create_vpc ? aws_subnet.private[*].ipv6_cidr_block : []
}

output "public_subnet_ipv6_cidr_blocks" {
  description = "IPv6 CIDR blocks of the public subnets"
  value       = var.create_vpc ? aws_subnet.public[*].ipv6_cidr_block : []
}

output "private_subnet_availability_zones" {
  description = "Availability zones of the private subnets"
  value       = var.create_vpc ? aws_subnet.private[*].availability_zone : []
}

output "public_subnet_availability_zones" {
  description = "Availability zones of the public subnets"
  value       = var.create_vpc ? aws_subnet.public[*].availability_zone : []
}

# =============================================================================
# Internet Gateway Outputs
# =============================================================================

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = var.create_vpc && var.create_internet_gateway ? aws_internet_gateway.main[0].id : null
}

output "internet_gateway_arn" {
  description = "ARN of the Internet Gateway"
  value       = var.create_vpc && var.create_internet_gateway ? aws_internet_gateway.main[0].arn : null
}

# =============================================================================
# EIP Outputs
# =============================================================================

output "nat_eip_ids" {
  description = "IDs of the NAT Gateway EIPs"
  value       = var.create_vpc && var.create_nat_gateways ? aws_eip.nat[*].id : []
}

output "nat_eip_public_ips" {
  description = "Public IP addresses of the NAT Gateway EIPs"
  value       = var.create_vpc && var.create_nat_gateways ? aws_eip.nat[*].public_ip : []
}

output "nat_eip_allocation_ids" {
  description = "Allocation IDs of the NAT Gateway EIPs"
  value       = var.create_vpc && var.create_nat_gateways ? aws_eip.nat[*].allocation_id : []
}

# =============================================================================
# NAT Gateway Outputs
# =============================================================================

output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways"
  value       = var.create_vpc && var.create_nat_gateways ? aws_nat_gateway.main[*].id : []
}

output "nat_gateway_public_ips" {
  description = "Public IP addresses of the NAT Gateways"
  value       = var.create_vpc && var.create_nat_gateways ? aws_nat_gateway.main[*].public_ip : []
}

output "nat_gateway_private_ips" {
  description = "Private IP addresses of the NAT Gateways"
  value       = var.create_vpc && var.create_nat_gateways ? aws_nat_gateway.main[*].private_ip : []
}

output "nat_gateway_connectivity_types" {
  description = "Connectivity types of the NAT Gateways"
  value       = var.create_vpc && var.create_nat_gateways ? aws_nat_gateway.main[*].connectivity_type : []
}

# =============================================================================
# Route Table Outputs
# =============================================================================

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = var.create_vpc ? aws_route_table.public[0].id : null
}

output "public_route_table_arn" {
  description = "ARN of the public route table"
  value       = var.create_vpc ? aws_route_table.public[0].arn : null
}

output "private_route_table_ids" {
  description = "IDs of the private route tables"
  value       = var.create_vpc && var.create_nat_gateways ? aws_route_table.private[*].id : []
}

output "private_route_table_arns" {
  description = "ARNs of the private route tables"
  value       = var.create_vpc && var.create_nat_gateways ? aws_route_table.private[*].arn : []
}

# =============================================================================
# VPN Outputs
# =============================================================================

output "vpn_gateway_id" {
  description = "ID of the VPN Gateway"
  value       = var.create_vpn_gateway ? aws_vpn_gateway.main[0].id : null
}

output "vpn_gateway_arn" {
  description = "ARN of the VPN Gateway"
  value       = var.create_vpn_gateway ? aws_vpn_gateway.main[0].arn : null
}

output "vpn_gateway_amazon_side_asn" {
  description = "Amazon side ASN of the VPN Gateway"
  value       = var.create_vpn_gateway ? aws_vpn_gateway.main[0].amazon_side_asn : null
}

output "customer_gateway_ids" {
  description = "IDs of the Customer Gateways"
  value = {
    for k, v in aws_customer_gateway.main : k => v.id
  }
}

output "customer_gateway_arns" {
  description = "ARNs of the Customer Gateways"
  value = {
    for k, v in aws_customer_gateway.main : k => v.arn
  }
}

output "customer_gateway_bgp_asns" {
  description = "BGP ASNs of the Customer Gateways"
  value = {
    for k, v in aws_customer_gateway.main : k => v.bgp_asn
  }
}

output "vpn_connection_ids" {
  description = "IDs of the VPN Connections"
  value = {
    for k, v in aws_vpn_connection.main : k => v.id
  }
}

output "vpn_connection_arns" {
  description = "ARNs of the VPN Connections"
  value = {
    for k, v in aws_vpn_connection.main : k => v.arn
  }
}

output "vpn_connection_tunnel1_addresses" {
  description = "Tunnel 1 addresses of the VPN Connections"
  value = {
    for k, v in aws_vpn_connection.main : k => v.tunnel1_address
  }
}

output "vpn_connection_tunnel2_addresses" {
  description = "Tunnel 2 addresses of the VPN Connections"
  value = {
    for k, v in aws_vpn_connection.main : k => v.tunnel2_address
  }
}

output "vpn_connection_tunnel1_cgw_inside_addresses" {
  description = "Tunnel 1 Customer Gateway inside addresses"
  value = {
    for k, v in aws_vpn_connection.main : k => v.tunnel1_cgw_inside_address
  }
}

output "vpn_connection_tunnel2_cgw_inside_addresses" {
  description = "Tunnel 2 Customer Gateway inside addresses"
  value = {
    for k, v in aws_vpn_connection.main : k => v.tunnel2_cgw_inside_address
  }
}

output "vpn_connection_tunnel1_vgw_inside_addresses" {
  description = "Tunnel 1 VPN Gateway inside addresses"
  value = {
    for k, v in aws_vpn_connection.main : k => v.tunnel1_vgw_inside_address
  }
}

output "vpn_connection_tunnel2_vgw_inside_addresses" {
  description = "Tunnel 2 VPN Gateway inside addresses"
  value = {
    for k, v in aws_vpn_connection.main : k => v.tunnel2_vgw_inside_address
  }
}

output "vpn_connection_states" {
  description = "States of the VPN Connections"
  value = {
    for k, v in aws_vpn_connection.main : k => v.tunnel1_address
  }
}

# =============================================================================
# Direct Connect Outputs
# =============================================================================

output "direct_connect_gateway_id" {
  description = "ID of the Direct Connect Gateway"
  value       = var.create_direct_connect_gateway ? aws_dx_gateway.main[0].id : null
}

output "direct_connect_gateway_arn" {
  description = "ARN of the Direct Connect Gateway"
  value       = var.create_direct_connect_gateway ? aws_dx_gateway.main[0].arn : null
}

output "direct_connect_gateway_amazon_side_asn" {
  description = "Amazon side ASN of the Direct Connect Gateway"
  value       = var.create_direct_connect_gateway ? aws_dx_gateway.main[0].amazon_side_asn : null
}

output "direct_connect_gateway_association_id" {
  description = "ID of the Direct Connect Gateway Association"
  value       = var.create_direct_connect_gateway && var.create_vpc ? aws_dx_gateway_association.main[0].id : null
}

# =============================================================================
# Transit Gateway Outputs
# =============================================================================

output "transit_gateway_id" {
  description = "ID of the Transit Gateway"
  value       = var.create_transit_gateway ? aws_ec2_transit_gateway.main[0].id : null
}

output "transit_gateway_arn" {
  description = "ARN of the Transit Gateway"
  value       = var.create_transit_gateway ? aws_ec2_transit_gateway.main[0].arn : null
}

output "transit_gateway_amazon_side_asn" {
  description = "Amazon side ASN of the Transit Gateway"
  value       = var.create_transit_gateway ? aws_ec2_transit_gateway.main[0].amazon_side_asn : null
}

output "transit_gateway_owner_id" {
  description = "Owner ID of the Transit Gateway"
  value       = var.create_transit_gateway ? aws_ec2_transit_gateway.main[0].owner_id : null
}

output "transit_gateway_vpc_attachment_id" {
  description = "ID of the Transit Gateway VPC Attachment"
  value       = var.create_transit_gateway && var.create_vpc ? aws_ec2_transit_gateway_vpc_attachment.main[0].id : null
}

output "transit_gateway_vpc_attachment_arn" {
  description = "ARN of the Transit Gateway VPC Attachment"
  value       = var.create_transit_gateway && var.create_vpc ? aws_ec2_transit_gateway_vpc_attachment.main[0].arn : null
}

output "transit_gateway_vpc_attachment_state" {
  description = "State of the Transit Gateway VPC Attachment"
  value       = var.create_transit_gateway && var.create_vpc ? aws_ec2_transit_gateway_vpc_attachment.main[0].state : null
}

# =============================================================================
# Security Group Outputs
# =============================================================================

output "vpn_security_group_id" {
  description = "ID of the VPN Security Group"
  value       = var.create_vpn_security_group ? aws_security_group.vpn[0].id : null
}

output "vpn_security_group_arn" {
  description = "ARN of the VPN Security Group"
  value       = var.create_vpn_security_group ? aws_security_group.vpn[0].arn : null
}

output "vpn_security_group_name" {
  description = "Name of the VPN Security Group"
  value       = var.create_vpn_security_group ? aws_security_group.vpn[0].name : null
}

# =============================================================================
# CloudWatch Logs Outputs
# =============================================================================

output "vpn_log_group_name" {
  description = "Name of the VPN CloudWatch Log Group"
  value       = var.create_vpn_logs ? aws_cloudwatch_log_group.vpn[0].name : null
}

output "vpn_log_group_arn" {
  description = "ARN of the VPN CloudWatch Log Group"
  value       = var.create_vpn_logs ? aws_cloudwatch_log_group.vpn[0].arn : null
}

# =============================================================================
# CloudWatch Alarms Outputs
# =============================================================================

output "cloudwatch_alarm_ids" {
  description = "IDs of the CloudWatch alarms"
  value = {
    for k, v in aws_cloudwatch_metric_alarm.main : k => v.id
  }
}

output "cloudwatch_alarm_arns" {
  description = "ARNs of the CloudWatch alarms"
  value = {
    for k, v in aws_cloudwatch_metric_alarm.main : k => v.arn
  }
}

# =============================================================================
# VPC Endpoints Outputs
# =============================================================================

output "vpc_endpoint_ids" {
  description = "IDs of the VPC endpoints"
  value = {
    for k, v in aws_vpc_endpoint.main : k => v.id
  }
}

output "vpc_endpoint_arns" {
  description = "ARNs of the VPC endpoints"
  value = {
    for k, v in aws_vpc_endpoint.main : k => v.arn
  }
}

output "vpc_endpoint_dns_entries" {
  description = "DNS entries of the VPC endpoints"
  value = {
    for k, v in aws_vpc_endpoint.main : k => v.dns_entry
  }
}

# =============================================================================
# IAM Outputs
# =============================================================================

output "vpn_monitoring_role_arn" {
  description = "ARN of the VPN monitoring IAM role"
  value       = var.create_vpn_monitoring_role ? aws_iam_role.vpn_monitoring[0].arn : null
}

output "vpn_monitoring_role_name" {
  description = "Name of the VPN monitoring IAM role"
  value       = var.create_vpn_monitoring_role ? aws_iam_role.vpn_monitoring[0].name : null
}

output "vpn_monitoring_role_id" {
  description = "ID of the VPN monitoring IAM role"
  value       = var.create_vpn_monitoring_role ? aws_iam_role.vpn_monitoring[0].id : null
}

output "vpn_monitoring_policy_id" {
  description = "ID of the VPN monitoring IAM policy"
  value       = var.create_vpn_monitoring_role ? aws_iam_role_policy.vpn_monitoring[0].id : null
}

# =============================================================================
# Summary Outputs
# =============================================================================

output "connectivity_summary" {
  description = "Summary of connectivity resources created"
  value = {
    vpc_created                    = var.create_vpc
    vpn_gateway_created           = var.create_vpn_gateway
    direct_connect_gateway_created = var.create_direct_connect_gateway
    transit_gateway_created        = var.create_transit_gateway
    customer_gateways_count        = length(var.customer_gateways)
    vpn_connections_count          = length(var.vpn_connections)
    private_subnets_count          = var.create_vpc ? length(var.private_subnet_cidrs) : 0
    public_subnets_count           = var.create_vpc ? length(var.public_subnet_cidrs) : 0
    nat_gateways_count             = var.create_vpc && var.create_nat_gateways ? length(var.public_subnet_cidrs) : 0
    cloudwatch_alarms_count        = var.create_cloudwatch_alarms ? length(var.cloudwatch_alarms) : 0
    vpc_endpoints_count            = var.create_vpc_endpoints ? length(var.vpc_endpoints) : 0
  }
}

output "configuration_summary" {
  description = "Detailed summary of configuration parameters"
  value = {
    vpc = {
      cidr_block                    = var.vpc_cidr_block
      ipv6_enabled                  = var.vpc_ipv6_cidr_block != null || var.vpc_assign_generated_ipv6_cidr_block
      instance_tenancy              = var.vpc_instance_tenancy
      dns_hostnames_enabled         = var.enable_dns_hostnames
      dns_support_enabled           = var.enable_dns_support
      network_usage_metrics_enabled = var.vpc_enable_network_address_usage_metrics
    }
    subnets = {
      private_subnets_count         = length(var.private_subnet_cidrs)
      public_subnets_count          = length(var.public_subnet_cidrs)
      private_ipv6_enabled          = length(var.private_subnet_ipv6_cidr_blocks) > 0
      public_ipv6_enabled           = length(var.public_subnet_ipv6_cidr_blocks) > 0
      map_public_ip_on_launch       = var.map_public_ip_on_launch
    }
    nat_gateways = {
      enabled                       = var.create_nat_gateways
      connectivity_type             = var.nat_gateway_connectivity_type
      private_ips_configured        = length(var.nat_gateway_private_ips) > 0
    }
    vpn = {
      gateway_enabled               = var.create_vpn_gateway
      amazon_side_asn               = var.vpn_gateway_amazon_side_asn
      connections_count             = length(var.vpn_connections)
      security_group_enabled        = var.create_vpn_security_group
      logs_enabled                  = var.create_vpn_logs
      monitoring_role_enabled       = var.create_vpn_monitoring_role
    }
    transit_gateway = {
      enabled                       = var.create_transit_gateway
      amazon_side_asn               = var.transit_gateway_amazon_side_asn
      multicast_support             = var.transit_gateway_multicast_support
      vpc_attachment_enabled        = var.create_transit_gateway && var.create_vpc
      appliance_mode_support        = var.transit_gateway_vpc_attachment_appliance_mode_support
      ipv6_support                  = var.transit_gateway_vpc_attachment_ipv6_support
    }
    direct_connect = {
      gateway_enabled               = var.create_direct_connect_gateway
      amazon_side_asn               = var.dx_gateway_amazon_side_asn
      allowed_prefixes_count        = length(var.dx_allowed_prefixes)
    }
    monitoring = {
      cloudwatch_alarms_enabled     = var.create_cloudwatch_alarms
      alarms_count                  = var.create_cloudwatch_alarms ? length(var.cloudwatch_alarms) : 0
    }
    vpc_endpoints = {
      enabled                       = var.create_vpc_endpoints
      endpoints_count               = var.create_vpc_endpoints ? length(var.vpc_endpoints) : 0
    }
  }
} 