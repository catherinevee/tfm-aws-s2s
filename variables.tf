# =============================================================================
# Variables for AWS Site-to-Site Connectivity Module
# =============================================================================

# =============================================================================
# General Configuration
# =============================================================================

variable "aws_region" {
  description = "AWS region to deploy resources. Must be a valid AWS region identifier."
  type        = string
  default     = "us-east-1"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.aws_region))
    error_message = "AWS region must contain only lowercase letters, numbers, and hyphens."
  }

  validation {
    condition = contains([
      "us-east-1", "us-east-2", "us-west-1", "us-west-2",
      "eu-west-1", "eu-west-2", "eu-west-3", "eu-central-1",
      "ap-southeast-1", "ap-southeast-2", "ap-northeast-1",
      "ca-central-1", "sa-east-1"
    ], var.aws_region)
    error_message = "AWS region must be a valid AWS region. Common regions: us-east-1, us-west-2, eu-west-1, etc."
  }
}

variable "name_prefix" {
  description = "Prefix to be used for resource naming"
  type        = string
  default     = "s2s" # Default: s2s

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.name_prefix))
    error_message = "Name prefix must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default = {
    Environment = "production" # Default: production
    Project     = "site-to-site-connectivity" # Default: site-to-site-connectivity
    ManagedBy   = "terraform" # Default: terraform
  }
}

# =============================================================================
# VPC Configuration
# =============================================================================

variable "create_vpc" {
  description = "Whether to create a new VPC"
  type        = bool
  default     = true # Default: true
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16" # Default: 10.0.0.0/16

  validation {
    condition     = can(cidrhost(var.vpc_cidr_block, 0))
    error_message = "VPC CIDR block must be a valid IPv4 CIDR block."
  }
}

variable "vpc_secondary_cidr_blocks" {
  description = "List of secondary CIDR blocks for the VPC"
  type        = list(string)
  default     = [] # Default: empty list

  validation {
    condition = alltrue([
      for cidr in var.vpc_secondary_cidr_blocks : can(cidrhost(cidr, 0))
    ])
    error_message = "All secondary CIDR blocks must be valid IPv4 CIDR blocks."
  }
}

variable "vpc_ipv6_cidr_block" {
  description = "IPv6 CIDR block for the VPC"
  type        = string
  default     = null # Default: null (no IPv6)

  validation {
    condition     = var.vpc_ipv6_cidr_block == null || can(cidrhost(var.vpc_ipv6_cidr_block, 0))
    error_message = "VPC IPv6 CIDR block must be a valid IPv6 CIDR block."
  }
}

variable "vpc_ipv6_cidr_block_network_border_group" {
  description = "Network border group for IPv6 CIDR block"
  type        = string
  default     = null # Default: null
}

variable "vpc_assign_generated_ipv6_cidr_block" {
  description = "Whether to assign a generated IPv6 CIDR block"
  type        = bool
  default     = false # Default: false
}

variable "enable_dns_hostnames" {
  description = "Whether to enable DNS hostnames in the VPC"
  type        = bool
  default     = true # Default: true
}

variable "enable_dns_support" {
  description = "Whether to enable DNS support in the VPC"
  type        = bool
  default     = true # Default: true
}

variable "vpc_instance_tenancy" {
  description = "Tenancy of instances launched into the VPC"
  type        = string
  default     = "default" # Default: default

  validation {
    condition     = contains(["default", "dedicated"], var.vpc_instance_tenancy)
    error_message = "VPC instance tenancy must be either 'default' or 'dedicated'."
  }
}

variable "vpc_enable_network_address_usage_metrics" {
  description = "Whether to enable network address usage metrics"
  type        = bool
  default     = false # Default: false
}

variable "vpc_tags" {
  description = "Additional tags for VPC resources"
  type        = map(string)
  default     = {} # Default: empty map
}

# =============================================================================
# Subnet Configuration
# =============================================================================

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"] # Default: 10.0.1.0/24, 10.0.2.0/24

  validation {
    condition = alltrue([
      for cidr in var.private_subnet_cidrs : can(cidrhost(cidr, 0))
    ])
    error_message = "All private subnet CIDR blocks must be valid IPv4 CIDR blocks."
  }
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"] # Default: 10.0.101.0/24, 10.0.102.0/24

  validation {
    condition = alltrue([
      for cidr in var.public_subnet_cidrs : can(cidrhost(cidr, 0))
    ])
    error_message = "All public subnet CIDR blocks must be valid IPv4 CIDR blocks."
  }
}

variable "private_subnet_ipv6_cidr_blocks" {
  description = "List of IPv6 CIDR blocks for private subnets"
  type        = list(string)
  default     = [] # Default: empty list

  validation {
    condition = alltrue([
      for cidr in var.private_subnet_ipv6_cidr_blocks : can(cidrhost(cidr, 0))
    ])
    error_message = "All private subnet IPv6 CIDR blocks must be valid IPv6 CIDR blocks."
  }
}

variable "public_subnet_ipv6_cidr_blocks" {
  description = "List of IPv6 CIDR blocks for public subnets"
  type        = list(string)
  default     = [] # Default: empty list

  validation {
    condition = alltrue([
      for cidr in var.public_subnet_ipv6_cidr_blocks : can(cidrhost(cidr, 0))
    ])
    error_message = "All public subnet IPv6 CIDR blocks must be valid IPv6 CIDR blocks."
  }
}

variable "private_subnet_assign_ipv6_address_on_creation" {
  description = "Whether to assign IPv6 addresses on creation for private subnets"
  type        = bool
  default     = false # Default: false
}

variable "public_subnet_assign_ipv6_address_on_creation" {
  description = "Whether to assign IPv6 addresses on creation for public subnets"
  type        = bool
  default     = false # Default: false
}

variable "private_subnet_outpost_arns" {
  description = "List of Outpost ARNs for private subnets"
  type        = list(string)
  default     = [] # Default: empty list
}

variable "public_subnet_outpost_arns" {
  description = "List of Outpost ARNs for public subnets"
  type        = list(string)
  default     = [] # Default: empty list
}

variable "map_public_ip_on_launch" {
  description = "Whether to map public IP on launch for public subnets"
  type        = bool
  default     = true # Default: true
}

variable "private_subnet_tags" {
  description = "Additional tags for private subnets"
  type        = map(string)
  default     = {} # Default: empty map
}

variable "public_subnet_tags" {
  description = "Additional tags for public subnets"
  type        = map(string)
  default     = {} # Default: empty map
}

# =============================================================================
# Internet Gateway Configuration
# =============================================================================

variable "create_internet_gateway" {
  description = "Whether to create an Internet Gateway"
  type        = bool
  default     = true # Default: true
}

variable "internet_gateway_tags" {
  description = "Additional tags for Internet Gateway"
  type        = map(string)
  default     = {} # Default: empty map
}

# =============================================================================
# EIP Configuration
# =============================================================================

variable "eip_domain" {
  description = "Domain for EIP resources"
  type        = string
  default     = "vpc" # Default: vpc

  validation {
    condition     = contains(["vpc", "standard"], var.eip_domain)
    error_message = "EIP domain must be either 'vpc' or 'standard'."
  }
}

variable "eip_network_border_group" {
  description = "Network border group for EIP"
  type        = string
  default     = null # Default: null
}

variable "eip_public_ipv4_pool" {
  description = "Public IPv4 pool for EIP"
  type        = string
  default     = null # Default: null
}

variable "eip_tags" {
  description = "Additional tags for EIP resources"
  type        = map(string)
  default     = {} # Default: empty map
}

# =============================================================================
# NAT Gateway Configuration
# =============================================================================

variable "create_nat_gateways" {
  description = "Whether to create NAT Gateways"
  type        = bool
  default     = true # Default: true
}

variable "nat_gateway_connectivity_type" {
  description = "Connectivity type for NAT Gateways"
  type        = string
  default     = "public" # Default: public

  validation {
    condition     = contains(["public", "private"], var.nat_gateway_connectivity_type)
    error_message = "NAT Gateway connectivity type must be either 'public' or 'private'."
  }
}

variable "nat_gateway_private_ips" {
  description = "List of private IP addresses for NAT Gateways"
  type        = list(string)
  default     = [] # Default: empty list
}

variable "nat_gateway_tags" {
  description = "Additional tags for NAT Gateways"
  type        = map(string)
  default     = {} # Default: empty map
}

# =============================================================================
# Route Table Configuration
# =============================================================================

variable "route_table_tags" {
  description = "Additional tags for route tables"
  type        = map(string)
  default     = {} # Default: empty map
}

variable "additional_public_routes" {
  description = "Additional routes for public route table"
  type = list(object({
    cidr_block                = string
    gateway_id                = optional(string)
    nat_gateway_id            = optional(string)
    network_interface_id      = optional(string)
    transit_gateway_id        = optional(string)
    vpc_endpoint_id           = optional(string)
    vpc_peering_connection_id = optional(string)
    egress_only_gateway_id    = optional(string)
    local_gateway_id          = optional(string)
    carrier_gateway_id        = optional(string)
    core_network_arn          = optional(string)
  }))
  default = [] # Default: empty list
}

variable "additional_private_routes" {
  description = "Additional routes for private route tables"
  type = list(object({
    cidr_block                = string
    gateway_id                = optional(string)
    nat_gateway_id            = optional(string)
    network_interface_id      = optional(string)
    transit_gateway_id        = optional(string)
    vpc_endpoint_id           = optional(string)
    vpc_peering_connection_id = optional(string)
    egress_only_gateway_id    = optional(string)
    local_gateway_id          = optional(string)
    carrier_gateway_id        = optional(string)
    core_network_arn          = optional(string)
  }))
  default = [] # Default: empty list
}

# =============================================================================
# VPN Configuration
# =============================================================================

variable "create_vpn_gateway" {
  description = "Whether to create a VPN Gateway"
  type        = bool
  default     = false # Default: false
}

variable "vpn_gateway_amazon_side_asn" {
  description = "Amazon side ASN for VPN Gateway"
  type        = number
  default     = 64512 # Default: 64512

  validation {
    condition     = var.vpn_gateway_amazon_side_asn >= 64512 && var.vpn_gateway_amazon_side_asn <= 65534
    error_message = "VPN Gateway Amazon side ASN must be between 64512 and 65534."
  }
}

variable "vpn_gateway_tags" {
  description = "Additional tags for VPN Gateway"
  type        = map(string)
  default     = {} # Default: empty map
}

variable "customer_gateways" {
  description = "Map of customer gateway configurations"
  type = map(object({
    bgp_asn    = number
    ip_address = string
    type       = optional(string, "ipsec.1") # Default: ipsec.1
    tags       = optional(map(string), {}) # Default: empty map
  }))
  default = {} # Default: empty map

  validation {
    condition = alltrue([
      for cgw in var.customer_gateways : cgw.bgp_asn > 0 && cgw.bgp_asn < 65536
    ])
    error_message = "BGP ASN must be between 1 and 65535."
  }
}

variable "vpn_connections" {
  description = "Map of VPN connection configurations"
  type = map(object({
    customer_gateway_key      = string
    static_routes_only        = bool
    tunnel1_inside_ipv6_cidr  = optional(string) # Default: null
    tunnel2_inside_ipv6_cidr  = optional(string) # Default: null
    tunnel1_preshared_key     = optional(string, null) # Default: null
    tunnel2_preshared_key     = optional(string, null) # Default: null
    tunnel1_dpd_timeout_action = optional(string, "clear") # Default: clear
    tunnel2_dpd_timeout_action = optional(string, "clear") # Default: clear
    tunnel1_dpd_timeout_seconds = optional(number, 30) # Default: 30
    tunnel2_dpd_timeout_seconds = optional(number, 30) # Default: 30
    tunnel1_ike_versions      = optional(list(string), ["ikev2"]) # Default: ["ikev2"]
    tunnel2_ike_versions      = optional(list(string), ["ikev2"]) # Default: ["ikev2"]
    tunnel1_phase1_dh_group_numbers = optional(list(number), [2, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]) # Default: [2, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]
    tunnel2_phase1_dh_group_numbers = optional(list(number), [2, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]) # Default: [2, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]
    tunnel1_phase1_encryption_algorithms = optional(list(string), ["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"]) # Default: ["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"]
    tunnel2_phase1_encryption_algorithms = optional(list(string), ["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"]) # Default: ["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"]
    tunnel1_phase1_integrity_algorithms = optional(list(string), ["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"]) # Default: ["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"]
    tunnel2_phase1_integrity_algorithms = optional(list(string), ["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"]) # Default: ["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"]
    tunnel1_phase2_dh_group_numbers = optional(list(number), [2, 5, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]) # Default: [2, 5, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]
    tunnel2_phase2_dh_group_numbers = optional(list(number), [2, 5, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]) # Default: [2, 5, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]
    tunnel1_phase2_encryption_algorithms = optional(list(string), ["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"]) # Default: ["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"]
    tunnel2_phase2_encryption_algorithms = optional(list(string), ["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"]) # Default: ["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"]
    tunnel1_phase2_integrity_algorithms = optional(list(string), ["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"]) # Default: ["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"]
    tunnel2_phase2_integrity_algorithms = optional(list(string), ["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"]) # Default: ["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"]
    tunnel1_rekey_fuzz_percentage = optional(number, 100) # Default: 100
    tunnel2_rekey_fuzz_percentage = optional(number, 100) # Default: 100
    tunnel1_rekey_margin_time_seconds = optional(number, 540) # Default: 540
    tunnel2_rekey_margin_time_seconds = optional(number, 540) # Default: 540
    tunnel1_replay_window_size = optional(number, 1024) # Default: 1024
    tunnel2_replay_window_size = optional(number, 1024) # Default: 1024
    tunnel1_startup_action = optional(string, "add") # Default: add
    tunnel2_startup_action = optional(string, "add") # Default: add
    tags = optional(map(string), {}) # Default: empty map
  }))
  default = {} # Default: empty map
}

variable "vpn_routes" {
  description = "Map of VPN route configurations"
  type = map(object({
    destination_cidr_block = string
    vpn_connection_key     = string
  }))
  default = {} # Default: empty map
}

variable "create_vpn_security_group" {
  description = "Whether to create a security group for VPN traffic"
  type        = bool
  default     = false # Default: false
}

variable "vpn_security_group_rules" {
  description = "List of security group rules for VPN traffic"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = [
    {
      from_port   = 500
      to_port     = 500
      protocol    = "udp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "IKE" # Default: IKE
    },
    {
      from_port   = 4500
      to_port     = 4500
      protocol    = "udp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "NAT-T" # Default: NAT-T
    }
  ]
}

variable "vpn_security_group_egress_rules" {
  description = "List of egress security group rules for VPN traffic"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "All traffic" # Default: All traffic
    }
  ]
}

variable "vpn_security_group_tags" {
  description = "Additional tags for VPN security group"
  type        = map(string)
  default     = {} # Default: empty map
}

variable "create_vpn_logs" {
  description = "Whether to create CloudWatch log group for VPN logs"
  type        = bool
  default     = false # Default: false
}

variable "vpn_log_retention_days" {
  description = "Number of days to retain VPN logs"
  type        = number
  default     = 30 # Default: 30

  validation {
    condition     = var.vpn_log_retention_days >= 1 && var.vpn_log_retention_days <= 3653
    error_message = "VPN log retention days must be between 1 and 3653."
  }
}

variable "vpn_log_kms_key_id" {
  description = "KMS key ID for VPN log encryption"
  type        = string
  default     = null # Default: null
}

variable "vpn_log_tags" {
  description = "Additional tags for VPN log group"
  type        = map(string)
  default     = {} # Default: empty map
}

variable "create_vpn_monitoring_role" {
  description = "Whether to create IAM role for VPN monitoring"
  type        = bool
  default     = false # Default: false
}

variable "vpn_monitoring_role_permissions_boundary" {
  description = "Permissions boundary for VPN monitoring role"
  type        = string
  default     = null # Default: null
}

variable "vpn_monitoring_role_tags" {
  description = "Additional tags for VPN monitoring role"
  type        = map(string)
  default     = {} # Default: empty map
}

# =============================================================================
# Direct Connect Configuration
# =============================================================================

variable "create_direct_connect_gateway" {
  description = "Whether to create a Direct Connect Gateway"
  type        = bool
  default     = false # Default: false
}

variable "dx_gateway_amazon_side_asn" {
  description = "Amazon side ASN for Direct Connect Gateway"
  type        = number
  default     = 64512 # Default: 64512

  validation {
    condition     = var.dx_gateway_amazon_side_asn >= 64512 && var.dx_gateway_amazon_side_asn <= 65534
    error_message = "Direct Connect Gateway Amazon side ASN must be between 64512 and 65534."
  }
}

variable "dx_gateway_tags" {
  description = "Additional tags for Direct Connect Gateway"
  type        = map(string)
  default     = {} # Default: empty map
}

variable "dx_allowed_prefixes" {
  description = "List of allowed prefixes for Direct Connect Gateway"
  type        = list(string)
  default     = [] # Default: empty list

  validation {
    condition = alltrue([
      for prefix in var.dx_allowed_prefixes : can(cidrhost(prefix, 0))
    ])
    error_message = "All Direct Connect allowed prefixes must be valid IPv4 CIDR blocks."
  }
}

variable "dx_gateway_association_tags" {
  description = "Additional tags for Direct Connect Gateway Association"
  type        = map(string)
  default     = {} # Default: empty map
}

# =============================================================================
# Transit Gateway Configuration
# =============================================================================

variable "create_transit_gateway" {
  description = "Whether to create a Transit Gateway"
  type        = bool
  default     = false # Default: false
}

variable "transit_gateway_amazon_side_asn" {
  description = "Amazon side ASN for Transit Gateway"
  type        = number
  default     = 64512 # Default: 64512

  validation {
    condition     = var.transit_gateway_amazon_side_asn >= 64512 && var.transit_gateway_amazon_side_asn <= 65534
    error_message = "Transit Gateway Amazon side ASN must be between 64512 and 65534."
  }
}

variable "transit_gateway_auto_accept_shared_attachments" {
  description = "Whether to auto accept shared attachments for Transit Gateway"
  type        = bool
  default     = false # Default: false
}

variable "transit_gateway_default_route_table_association" {
  description = "Whether to enable default route table association for Transit Gateway"
  type        = bool
  default     = true # Default: true
}

variable "transit_gateway_default_route_table_propagation" {
  description = "Whether to enable default route table propagation for Transit Gateway"
  type        = bool
  default     = true # Default: true
}

variable "transit_gateway_dns_support" {
  description = "Whether to enable DNS support for Transit Gateway"
  type        = bool
  default     = true # Default: true
}

variable "transit_gateway_vpn_ecmp_support" {
  description = "Whether to enable VPN ECMP support for Transit Gateway"
  type        = bool
  default     = true # Default: true
}

variable "transit_gateway_multicast_support" {
  description = "Whether to enable multicast support for Transit Gateway"
  type        = bool
  default     = false # Default: false
}

variable "transit_gateway_tags" {
  description = "Additional tags for Transit Gateway"
  type        = map(string)
  default     = {} # Default: empty map
}

variable "transit_gateway_vpc_attachment_default_route_table_association" {
  description = "Whether to enable default route table association for Transit Gateway VPC attachment"
  type        = bool
  default     = true # Default: true
}

variable "transit_gateway_vpc_attachment_default_route_table_propagation" {
  description = "Whether to enable default route table propagation for Transit Gateway VPC attachment"
  type        = bool
  default     = true # Default: true
}

variable "transit_gateway_vpc_attachment_appliance_mode_support" {
  description = "Whether to enable appliance mode support for Transit Gateway VPC attachment"
  type        = bool
  default     = false # Default: false
}

variable "transit_gateway_vpc_attachment_dns_support" {
  description = "Whether to enable DNS support for Transit Gateway VPC attachment"
  type        = bool
  default     = true # Default: true
}

variable "transit_gateway_vpc_attachment_ipv6_support" {
  description = "Whether to enable IPv6 support for Transit Gateway VPC attachment"
  type        = bool
  default     = false # Default: false
}

variable "transit_gateway_vpc_attachment_tags" {
  description = "Additional tags for Transit Gateway VPC attachment"
  type        = map(string)
  default     = {} # Default: empty map
}

# =============================================================================
# CloudWatch Alarms Configuration
# =============================================================================

variable "create_cloudwatch_alarms" {
  description = "Whether to create CloudWatch alarms for monitoring"
  type        = bool
  default     = false # Default: false
}

variable "cloudwatch_alarms" {
  description = "Map of CloudWatch alarm configurations"
  type = map(object({
    alarm_name          = string
    comparison_operator = string
    evaluation_periods  = number
    metric_name         = string
    namespace           = string
    period              = number
    statistic           = string
    threshold           = number
    alarm_description   = optional(string) # Default: null
    alarm_actions       = optional(list(string), []) # Default: empty list
    ok_actions          = optional(list(string), []) # Default: empty list
    insufficient_data_actions = optional(list(string), []) # Default: empty list
    treat_missing_data  = optional(string, "missing") # Default: missing
    unit                = optional(string) # Default: null
    extended_statistic  = optional(string) # Default: null
    datapoints_to_alarm = optional(number) # Default: null
    threshold_metric_id = optional(string) # Default: null
    dimensions = optional(list(object({
      name  = string
      value = string
    })), []) # Default: empty list
    metric_query = optional(list(object({
      id          = string
      expression  = optional(string) # Default: null
      label       = optional(string) # Default: null
      return_data = optional(bool, true) # Default: true
      metric = optional(object({
        metric_name = string
        namespace   = string
        period      = number
        stat        = string
        unit        = optional(string) # Default: null
        dimensions = optional(list(object({
          name  = string
          value = string
        })), []) # Default: empty list
      })) # Default: null
    })), []) # Default: empty list
    tags = optional(map(string), {}) # Default: empty map
  }))
  default = {} # Default: empty map
}

# =============================================================================
# VPC Endpoints Configuration
# =============================================================================

variable "create_vpc_endpoints" {
  description = "Whether to create VPC endpoints"
  type        = bool
  default     = false # Default: false
}

variable "vpc_endpoints" {
  description = "Map of VPC endpoint configurations"
  type = map(object({
    service_name             = string
    vpc_endpoint_type        = optional(string, "Gateway") # Default: Gateway
    private_dns_enabled      = optional(bool, true) # Default: true
    subnet_ids               = optional(list(string), []) # Default: empty list
    security_group_ids       = optional(list(string), []) # Default: empty list
    policy                   = optional(string, null) # Default: null
    route_table_ids          = optional(list(string), []) # Default: empty list
    tags                     = optional(map(string), {}) # Default: empty map
  }))
  default = {} # Default: empty map
}

# =============================================================================
# VPC Flow Logs Configuration
# =============================================================================

variable "enable_vpc_flow_logs" {
  description = "Whether to enable VPC Flow Logs for network monitoring and troubleshooting"
  type        = bool
  default     = false
}

variable "vpc_flow_log_format" {
  description = "The format for VPC Flow Logs. Use default format or specify custom fields"
  type        = string
  default     = "$${version} $${account-id} $${interface-id} $${srcaddr} $${dstaddr} $${srcport} $${dstport} $${protocol} $${packets} $${bytes} $${windowstart} $${windowend} $${action} $${flowlogstatus}"

  validation {
    condition     = can(regex("\\$\\{", var.vpc_flow_log_format))
    error_message = "VPC Flow Log format must contain at least one field placeholder (e.g., ${version})."
  }
}

variable "vpc_flow_log_max_aggregation_interval" {
  description = "Maximum interval of time in seconds during which a flow is captured and aggregated"
  type        = number
  default     = 600

  validation {
    condition     = contains([60, 600], var.vpc_flow_log_max_aggregation_interval)
    error_message = "VPC Flow Log max aggregation interval must be either 60 or 600 seconds."
  }
}

variable "vpc_flow_log_retention_days" {
  description = "Number of days to retain VPC Flow Logs in CloudWatch"
  type        = number
  default     = 14

  validation {
    condition = contains([
      1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653
    ], var.vpc_flow_log_retention_days)
    error_message = "VPC Flow Log retention days must be a valid CloudWatch Logs retention period."
  }
}

variable "vpc_flow_log_kms_key_id" {
  description = "KMS key ID for VPC Flow Logs encryption"
  type        = string
  default     = null
}

variable "vpc_flow_log_cross_account_role" {
  description = "ARN of the IAM role for cross-account VPC Flow Logs delivery"
  type        = string
  default     = null
}

variable "vpc_flow_log_tags" {
  description = "Additional tags for VPC Flow Logs resources"
  type        = map(string)
  default     = {}
} 