# =============================================================================
# Transit Gateway Example
# =============================================================================
# This example demonstrates a Transit Gateway setup for centralized
# connectivity between multiple VPCs and on-premises networks.

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "site_to_site" {
  source = "../../"

  name_prefix = "transit-gateway"
  aws_region  = "us-east-1"

  # VPC Configuration with multiple CIDR blocks
  vpc_cidr_block              = "10.0.0.0/16"
  vpc_secondary_cidr_blocks   = ["10.1.0.0/16", "10.2.0.0/16"]
  private_subnet_cidrs        = ["10.0.1.0/24", "10.0.2.0/24", "10.1.1.0/24", "10.1.2.0/24"]
  public_subnet_cidrs         = ["10.0.101.0/24", "10.0.102.0/24"]

  # Transit Gateway Configuration
  create_transit_gateway = true
  transit_gateway_amazon_side_asn = 64512
  transit_gateway_auto_accept_shared_attachments = false
  transit_gateway_default_route_table_association = true
  transit_gateway_default_route_table_propagation = true
  transit_gateway_dns_support = true
  transit_gateway_vpn_ecmp_support = true

  # VPN Configuration for Transit Gateway
  create_vpn_gateway = true
  customer_gateways = {
    primary = {
      bgp_asn    = 65000
      ip_address = "203.0.113.1"
    }
    secondary = {
      bgp_asn    = 65001
      ip_address = "203.0.113.2"
    }
  }

  vpn_connections = {
    primary = {
      customer_gateway_key = "primary"
      static_routes_only   = false
    }
    secondary = {
      customer_gateway_key = "secondary"
      static_routes_only   = false
    }
  }

  vpn_routes = {
    on_premises_network = {
      destination_cidr_block = "192.168.0.0/16"
      vpn_connection_key     = "primary"
    }
    branch_office = {
      destination_cidr_block = "172.16.0.0/12"
      vpn_connection_key     = "secondary"
    }
  }

  # Security and Monitoring
  create_vpn_security_group = true
  create_vpn_logs          = true
  create_vpn_monitoring_role = true

  vpn_security_group_rules = [
    {
      from_port   = 500
      to_port     = 500
      protocol    = "udp"
      cidr_blocks = ["203.0.113.0/24"]
      description = "IKE from on-premises"
    },
    {
      from_port   = 4500
      to_port     = 4500
      protocol    = "udp"
      cidr_blocks = ["203.0.113.0/24"]
      description = "NAT-T from on-premises"
    }
  ]

  common_tags = {
    Environment = "production"
    Project     = "multi-vpc-hub"
    CostCenter  = "network-infrastructure"
    Owner       = "enterprise-architects"
  }
} 