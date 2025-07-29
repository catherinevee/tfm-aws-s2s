# =============================================================================
# Basic VPN Example
# =============================================================================
# This example demonstrates a basic site-to-site VPN setup between
# on-premises networks and AWS Cloud.

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

  name_prefix = "basic-vpn"
  aws_region  = "us-east-1"

  # VPC Configuration
  vpc_cidr_block        = "10.0.0.0/16"
  private_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnet_cidrs   = ["10.0.101.0/24", "10.0.102.0/24"]

  # VPN Configuration
  create_vpn_gateway = true
  customer_gateways = {
    primary = {
      bgp_asn    = 65000
      ip_address = "203.0.113.1"
    }
  }

  vpn_connections = {
    primary = {
      customer_gateway_key = "primary"
      static_routes_only   = false
    }
  }

  vpn_routes = {
    on_premises_network = {
      destination_cidr_block = "192.168.0.0/16"
      vpn_connection_key     = "primary"
    }
  }

  # Security and Monitoring
  create_vpn_security_group = true
  create_vpn_logs          = true

  common_tags = {
    Environment = "development"
    Project     = "basic-vpn-demo"
    Owner       = "network-team"
  }
} 