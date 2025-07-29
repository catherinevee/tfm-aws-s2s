# =============================================================================
# Test Outputs for AWS Site-to-Site Connectivity Module
# =============================================================================

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.site_to_site_test.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = module.site_to_site_test.vpc_cidr_block
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.site_to_site_test.private_subnet_ids
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.site_to_site_test.public_subnet_ids
}

output "vpn_gateway_id" {
  description = "ID of the VPN Gateway"
  value       = module.site_to_site_test.vpn_gateway_id
}

output "customer_gateway_ids" {
  description = "IDs of the Customer Gateways"
  value       = module.site_to_site_test.customer_gateway_ids
}

output "vpn_connection_ids" {
  description = "IDs of the VPN Connections"
  value       = module.site_to_site_test.vpn_connection_ids
}

output "vpn_security_group_id" {
  description = "ID of the VPN Security Group"
  value       = module.site_to_site_test.vpn_security_group_id
}

output "vpn_log_group_name" {
  description = "Name of the VPN CloudWatch Log Group"
  value       = module.site_to_site_test.vpn_log_group_name
}

output "vpn_monitoring_role_arn" {
  description = "ARN of the VPN monitoring IAM role"
  value       = module.site_to_site_test.vpn_monitoring_role_arn
}

output "connectivity_summary" {
  description = "Summary of connectivity resources created"
  value       = module.site_to_site_test.connectivity_summary
} 