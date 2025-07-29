# =============================================================================
# Outputs for Basic VPN Example
# =============================================================================

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.site_to_site.vpc_id
}

output "vpn_gateway_id" {
  description = "ID of the VPN Gateway"
  value       = module.site_to_site.vpn_gateway_id
}

output "customer_gateway_ids" {
  description = "IDs of the Customer Gateways"
  value       = module.site_to_site.customer_gateway_ids
}

output "vpn_connection_ids" {
  description = "IDs of the VPN Connections"
  value       = module.site_to_site.vpn_connection_ids
}

output "vpn_connection_tunnel1_addresses" {
  description = "Tunnel 1 addresses of the VPN Connections"
  value       = module.site_to_site.vpn_connection_tunnel1_addresses
}

output "vpn_connection_tunnel2_addresses" {
  description = "Tunnel 2 addresses of the VPN Connections"
  value       = module.site_to_site.vpn_connection_tunnel2_addresses
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.site_to_site.private_subnet_ids
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.site_to_site.public_subnet_ids
}

output "connectivity_summary" {
  description = "Summary of connectivity resources created"
  value       = module.site_to_site.connectivity_summary
} 