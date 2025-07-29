# =============================================================================
# Test Configuration for AWS Site-to-Site Connectivity Module
# =============================================================================
# This configuration is used to test the module functionality
# and validate that all resources are created correctly.

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

module "site_to_site_test" {
  source = "../"

  name_prefix = "test-s2s"
  aws_region  = "us-east-1"

  # VPC Configuration
  vpc_cidr_block        = "10.100.0.0/16"
  private_subnet_cidrs  = ["10.100.1.0/24", "10.100.2.0/24"]
  public_subnet_cidrs   = ["10.100.101.0/24", "10.100.102.0/24"]

  # VPN Configuration
  create_vpn_gateway = true
  customer_gateways = {
    test_primary = {
      bgp_asn    = 65000
      ip_address = "203.0.113.10"
    }
  }

  vpn_connections = {
    test_primary = {
      customer_gateway_key = "test_primary"
      static_routes_only   = true
    }
  }

  vpn_routes = {
    test_on_premises = {
      destination_cidr_block = "192.168.100.0/24"
      vpn_connection_key     = "test_primary"
    }
  }

  # Security and Monitoring
  create_vpn_security_group = true
  create_vpn_logs          = true
  create_vpn_monitoring_role = true

  common_tags = {
    Environment = "test"
    Project     = "module-testing"
    Owner       = "qa-team"
    TestRun     = "true"
  }
} 