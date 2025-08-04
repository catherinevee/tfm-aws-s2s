# =============================================================================
# Variable Validation Rules
# =============================================================================

# Cross-variable validation for subnet CIDR blocks
locals {
  # Validate that private and public subnets don't overlap
  subnet_validation = {
    for private_cidr in var.private_subnet_cidrs :
    private_cidr => {
      for public_cidr in var.public_subnet_cidrs :
      public_cidr => !can(cidrhost(private_cidr, 0)) || !can(cidrhost(public_cidr, 0)) ||
      !cidrhost(private_cidr, 0) == cidrhost(public_cidr, 0)
    }
  }

  # Validate that all subnet CIDRs fit within VPC CIDR
  vpc_subnet_containment = {
    private_valid = alltrue([
      for cidr in var.private_subnet_cidrs :
      can(cidrsubnet(var.vpc_cidr_block, 0, 0)) &&
      can(cidrhost(cidr, 0))
    ])
    public_valid = alltrue([
      for cidr in var.public_subnet_cidrs :
      can(cidrsubnet(var.vpc_cidr_block, 0, 0)) &&
      can(cidrhost(cidr, 0))
    ])
  }

  # Validate VPN configuration consistency
  vpn_config_validation = {
    connections_have_gateways = alltrue([
      for conn_key, conn in var.vpn_connections :
      contains(keys(var.customer_gateways), conn.customer_gateway_key)
    ])
    routes_have_connections = alltrue([
      for route_key, route in var.vpn_routes :
      contains(keys(var.vpn_connections), route.vpn_connection_key)
    ])
  }
}

# Validation checks
check "subnet_overlap_validation" {
  assert {
    condition = alltrue([
      for validation in values(local.subnet_validation) :
      alltrue(values(validation))
    ])
    error_message = "Private and public subnet CIDR blocks must not overlap."
  }
}

check "vpc_subnet_containment_validation" {
  assert {
    condition     = local.vpc_subnet_containment.private_valid && local.vpc_subnet_containment.public_valid
    error_message = "All subnet CIDR blocks must be contained within the VPC CIDR block."
  }
}

check "vpn_configuration_validation" {
  assert {
    condition = local.vpn_config_validation.connections_have_gateways
    error_message = "All VPN connections must reference existing customer gateways."
  }

  assert {
    condition = local.vpn_config_validation.routes_have_connections
    error_message = "All VPN routes must reference existing VPN connections."
  }
}

check "resource_naming_validation" {
  assert {
    condition = length(var.name_prefix) >= 2 && length(var.name_prefix) <= 20
    error_message = "Name prefix must be between 2 and 20 characters for optimal resource naming."
  }
}

check "high_availability_validation" {
  assert {
    condition = length(var.private_subnet_cidrs) >= 2 || length(var.public_subnet_cidrs) >= 2
    error_message = "For high availability, deploy subnets across at least 2 availability zones."
  }
}
