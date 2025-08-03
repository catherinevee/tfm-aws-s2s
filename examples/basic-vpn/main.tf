# =============================================================================
# Basic VPN Example with Enhanced Features
# =============================================================================
# This example demonstrates a comprehensive site-to-site VPN setup between
# on-premises networks and AWS Cloud with enhanced customization options.

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

  name_prefix = "enhanced-vpn"
  aws_region  = "us-east-1"

  # Enhanced VPC Configuration
  vpc_cidr_block        = "10.0.0.0/16"
  vpc_ipv6_cidr_block   = "2001:db8::/56" # IPv6 CIDR block
  vpc_instance_tenancy  = "default"
  enable_dns_hostnames  = true
  enable_dns_support    = true

  # Enhanced Subnet Configuration
  private_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnet_cidrs   = ["10.0.101.0/24", "10.0.102.0/24"]
  
  # IPv6 Subnet Configuration
  private_subnet_ipv6_cidr_blocks = ["2001:db8::/64", "2001:db8:0:1::/64"]
  public_subnet_ipv6_cidr_blocks  = ["2001:db8:0:100::/64", "2001:db8:0:101::/64"]
  
  private_subnet_assign_ipv6_address_on_creation = true
  public_subnet_assign_ipv6_address_on_creation  = true
  
  map_public_ip_on_launch = true

  # Enhanced NAT Gateway Configuration
  create_nat_gateways = true
  nat_gateway_connectivity_type = "public"
  nat_gateway_private_ips = ["10.0.101.10", "10.0.102.10"]

  # Enhanced EIP Configuration
  eip_domain = "vpc"
  eip_network_border_group = "us-east-1"

  # Additional Routes Configuration
  additional_public_routes = [
    {
      cidr_block = "172.16.0.0/12"
      gateway_id = null # Will be set to IGW
    }
  ]

  additional_private_routes = [
    {
      cidr_block = "192.168.0.0/16"
      nat_gateway_id = null # Will be set to NAT Gateway
    }
  ]

  # Enhanced VPN Configuration
  create_vpn_gateway = true
  vpn_gateway_amazon_side_asn = 64512

  customer_gateways = {
    primary = {
      bgp_asn    = 65000
      ip_address = "203.0.113.1"
      type       = "ipsec.1"
      tags = {
        Environment = "production"
        Location    = "datacenter-1"
      }
    }
    secondary = {
      bgp_asn    = 65001
      ip_address = "203.0.113.2"
      type       = "ipsec.1"
      tags = {
        Environment = "production"
        Location    = "datacenter-2"
      }
    }
  }

  vpn_connections = {
    primary = {
      customer_gateway_key = "primary"
      static_routes_only   = false
      
      # Enhanced Tunnel Configuration
      tunnel1_preshared_key = "your-preshared-key-1"
      tunnel2_preshared_key = "your-preshared-key-2"
      
      tunnel1_dpd_timeout_action = "clear"
      tunnel2_dpd_timeout_action = "clear"
      
      tunnel1_dpd_timeout_seconds = 30
      tunnel2_dpd_timeout_seconds = 30
      
      tunnel1_ike_versions = ["ikev2"]
      tunnel2_ike_versions = ["ikev2"]
      
      tunnel1_phase1_encryption_algorithms = ["AES256", "AES256-GCM-16"]
      tunnel2_phase1_encryption_algorithms = ["AES256", "AES256-GCM-16"]
      
      tunnel1_phase1_integrity_algorithms = ["SHA2-256", "SHA2-384"]
      tunnel2_phase1_integrity_algorithms = ["SHA2-256", "SHA2-384"]
      
      tunnel1_phase2_encryption_algorithms = ["AES256", "AES256-GCM-16"]
      tunnel2_phase2_encryption_algorithms = ["AES256", "AES256-GCM-16"]
      
      tunnel1_phase2_integrity_algorithms = ["SHA2-256", "SHA2-384"]
      tunnel2_phase2_integrity_algorithms = ["SHA2-256", "SHA2-384"]
      
      tunnel1_rekey_fuzz_percentage = 100
      tunnel2_rekey_fuzz_percentage = 100
      
      tunnel1_rekey_margin_time_seconds = 540
      tunnel2_rekey_margin_time_seconds = 540
      
      tunnel1_replay_window_size = 1024
      tunnel2_replay_window_size = 1024
      
      tunnel1_startup_action = "add"
      tunnel2_startup_action = "add"
      
      tags = {
        Environment = "production"
        Connection  = "primary"
      }
    }
    secondary = {
      customer_gateway_key = "secondary"
      static_routes_only   = false
      
      tunnel1_preshared_key = "your-preshared-key-3"
      tunnel2_preshared_key = "your-preshared-key-4"
      
      tags = {
        Environment = "production"
        Connection  = "secondary"
      }
    }
  }

  vpn_routes = {
    on_premises_network_1 = {
      destination_cidr_block = "192.168.0.0/16"
      vpn_connection_key     = "primary"
    }
    on_premises_network_2 = {
      destination_cidr_block = "172.16.0.0/12"
      vpn_connection_key     = "secondary"
    }
  }

  # Enhanced Security Group Configuration
  create_vpn_security_group = true
  vpn_security_group_rules = [
    {
      from_port   = 500
      to_port     = 500
      protocol    = "udp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "IKE"
    },
    {
      from_port   = 4500
      to_port     = 4500
      protocol    = "udp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "NAT-T"
    },
    {
      from_port   = 50
      to_port     = 50
      protocol    = "esp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "ESP"
    }
  ]

  vpn_security_group_egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "All traffic"
    }
  ]

  # Enhanced CloudWatch Logs Configuration
  create_vpn_logs = true
  vpn_log_retention_days = 30
  vpn_log_kms_key_id = null # Set to KMS key ARN if encryption is needed

  # Enhanced IAM Role Configuration
  create_vpn_monitoring_role = true
  vpn_monitoring_role_permissions_boundary = null # Set to permissions boundary ARN if needed

  # Enhanced CloudWatch Alarms Configuration
  create_cloudwatch_alarms = true
  cloudwatch_alarms = {
    vpn_tunnel_down = {
      alarm_name          = "vpn-tunnel-down"
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 2
      metric_name         = "TunnelState"
      namespace           = "AWS/VPN"
      period              = 300
      statistic           = "Average"
      threshold           = 0
      alarm_description   = "VPN tunnel is down"
      treat_missing_data  = "breaching"
      dimensions = [
        {
          name  = "VpnId"
          value = "vpn-12345678" # Replace with actual VPN ID
        }
      ]
      tags = {
        Environment = "production"
        AlarmType   = "vpn"
      }
    }
    vpn_tunnel_data_in = {
      alarm_name          = "vpn-tunnel-data-in"
      comparison_operator = "LessThanThreshold"
      evaluation_periods  = 3
      metric_name         = "TunnelDataIn"
      namespace           = "AWS/VPN"
      period              = 300
      statistic           = "Average"
      threshold           = 1000
      alarm_description   = "VPN tunnel data in is low"
      treat_missing_data  = "notBreaching"
      dimensions = [
        {
          name  = "VpnId"
          value = "vpn-12345678" # Replace with actual VPN ID
        }
      ]
      tags = {
        Environment = "production"
        AlarmType   = "vpn"
      }
    }
  }

  # Enhanced VPC Endpoints Configuration
  create_vpc_endpoints = true
  vpc_endpoints = {
    s3 = {
      service_name       = "com.amazonaws.us-east-1.s3"
      vpc_endpoint_type  = "Gateway"
      private_dns_enabled = true
      route_table_ids    = [] # Will be populated with private route table IDs
      tags = {
        Environment = "production"
        Service     = "s3"
      }
    }
    dynamodb = {
      service_name       = "com.amazonaws.us-east-1.dynamodb"
      vpc_endpoint_type  = "Gateway"
      private_dns_enabled = true
      route_table_ids    = [] # Will be populated with private route table IDs
      tags = {
        Environment = "production"
        Service     = "dynamodb"
      }
    }
  }

  # Enhanced Transit Gateway Configuration (Optional)
  create_transit_gateway = false # Set to true if needed
  transit_gateway_amazon_side_asn = 64512
  transit_gateway_multicast_support = false
  transit_gateway_vpc_attachment_appliance_mode_support = false
  transit_gateway_vpc_attachment_ipv6_support = true

  # Enhanced Direct Connect Configuration (Optional)
  create_direct_connect_gateway = false # Set to true if needed
  dx_gateway_amazon_side_asn = 64512
  dx_allowed_prefixes = ["10.0.0.0/16", "192.168.0.0/16"]

  # Enhanced Tags Configuration
  common_tags = {
    Environment = "production"
    Project     = "enhanced-vpn-demo"
    Owner       = "network-team"
    CostCenter  = "network-infrastructure"
    Compliance  = "pci-dss"
  }

  # Resource-specific tags
  vpc_tags = {
    Purpose = "vpn-connectivity"
  }
  
  private_subnet_tags = {
    Tier = "private"
    Purpose = "application-servers"
  }
  
  public_subnet_tags = {
    Tier = "public"
    Purpose = "nat-gateways"
  }
  
  internet_gateway_tags = {
    Purpose = "internet-access"
  }
  
  eip_tags = {
    Purpose = "nat-gateway-eips"
  }
  
  nat_gateway_tags = {
    Purpose = "outbound-internet-access"
  }
  
  route_table_tags = {
    Purpose = "routing"
  }
  
  vpn_gateway_tags = {
    Purpose = "vpn-connectivity"
  }
  
  vpn_security_group_tags = {
    Purpose = "vpn-traffic"
  }
  
  vpn_log_tags = {
    Purpose = "vpn-monitoring"
  }
  
  vpn_monitoring_role_tags = {
    Purpose = "vpn-monitoring"
  }
} 