# =============================================================================
# Direct Connect Example
# =============================================================================
# This example demonstrates a Direct Connect setup for dedicated
# network connectivity between on-premises and AWS Cloud.

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

  name_prefix = "direct-connect"
  aws_region  = "us-east-1"

  # VPC Configuration
  vpc_cidr_block        = "10.0.0.0/16"
  private_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnet_cidrs   = ["10.0.101.0/24", "10.0.102.0/24"]

  # Direct Connect Configuration
  create_direct_connect_gateway = true
  dx_gateway_amazon_side_asn    = 64512
  dx_allowed_prefixes          = [
    "192.168.0.0/16",    # On-premises network
    "172.16.0.0/12",     # Additional on-premises network
    "10.1.0.0/16"        # Branch office network
  ]

  # Security and Monitoring
  create_vpn_security_group = true
  create_vpn_logs          = true
  create_vpn_monitoring_role = true

  common_tags = {
    Environment = "production"
    Project     = "enterprise-connectivity"
    CostCenter  = "network-infrastructure"
    Owner       = "enterprise-architects"
  }
} 