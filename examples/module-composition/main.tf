# =============================================================================
# Module Composition Examples
# =============================================================================
# These examples demonstrate how to compose multiple instances of this module
# for complex enterprise architectures.

# Example 1: Multi-Region Hub-and-Spoke Architecture
# Deploy this module in each region and connect via Transit Gateway peering

# Primary Region (us-east-1)
module "primary_region_connectivity" {
  source = "../"
  
  name_prefix = "primary-hub"
  aws_region  = "us-east-1"
  
  create_transit_gateway = true
  create_vpn_gateway     = true
  
  # Primary region configuration
  vpc_cidr_block = "10.0.0.0/16"
  
  providers = {
    aws = aws.us_east_1
  }
}

# Secondary Region (us-west-2)
module "secondary_region_connectivity" {
  source = "../"
  
  name_prefix = "secondary-hub"
  aws_region  = "us-west-2"
  
  create_transit_gateway = true
  
  # Secondary region configuration
  vpc_cidr_block = "10.1.0.0/16"
  
  providers = {
    aws = aws.us_west_2
  }
}

# Example 2: Environment-Specific Connectivity
# Different configurations for dev, staging, and production

module "dev_connectivity" {
  source = "../"
  
  name_prefix = "dev"
  
  # Development environment - minimal resources
  create_vpc             = true
  create_nat_gateways    = false  # Cost optimization
  create_vpn_gateway     = false  # Use Transit Gateway attachment
  create_transit_gateway = true
  
  common_tags = {
    Environment = "development"
    CostCenter  = "engineering"
  }
}

module "prod_connectivity" {
  source = "../"
  
  name_prefix = "prod"
  
  # Production environment - full redundancy
  create_vpc                = true
  create_nat_gateways      = true
  create_vpn_gateway       = true
  create_transit_gateway   = true
  create_direct_connect_gateway = true
  
  # Enhanced monitoring for production
  create_connectivity_alerts    = true
  create_monitoring_dashboard   = true
  enable_vpc_flow_logs         = true
  
  common_tags = {
    Environment = "production"
    CostCenter  = "infrastructure"
    Compliance  = "sox"
  }
}
