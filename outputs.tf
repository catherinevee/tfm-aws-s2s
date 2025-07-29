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

# =============================================================================
# Internet Gateway Outputs
# =============================================================================

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = var.create_vpc && var.create_internet_gateway ? aws_internet_gateway.main[0].id : null
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
  value       = var.create_vpc && var.create_nat_gateways ? aws_eip.nat[*].public_ip : []
}

# =============================================================================
# Route Table Outputs
# =============================================================================

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = var.create_vpc ? aws_route_table.public[0].id : null
}

output "private_route_table_ids" {
  description = "IDs of the private route tables"
  value       = var.create_vpc && var.create_nat_gateways ? aws_route_table.private[*].id : []
}

# =============================================================================
# VPN Outputs
# =============================================================================

output "vpn_gateway_id" {
  description = "ID of the VPN Gateway"
  value       = var.create_vpn_gateway ? aws_vpn_gateway.main[0].id : null
}

output "customer_gateway_ids" {
  description = "IDs of the Customer Gateways"
  value = {
    for k, v in aws_customer_gateway.main : k => v.id
  }
}

output "vpn_connection_ids" {
  description = "IDs of the VPN Connections"
  value = {
    for k, v in aws_vpn_connection.main : k => v.id
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

# =============================================================================
# Direct Connect Outputs
# =============================================================================

output "direct_connect_gateway_id" {
  description = "ID of the Direct Connect Gateway"
  value       = var.create_direct_connect_gateway ? aws_dx_gateway.main[0].id : null
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

output "transit_gateway_vpc_attachment_id" {
  description = "ID of the Transit Gateway VPC Attachment"
  value       = var.create_transit_gateway && var.create_vpc ? aws_ec2_transit_gateway_vpc_attachment.main[0].id : null
}

# =============================================================================
# Security Group Outputs
# =============================================================================

output "vpn_security_group_id" {
  description = "ID of the VPN Security Group"
  value       = var.create_vpn_security_group ? aws_security_group.vpn[0].id : null
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
  }
} 