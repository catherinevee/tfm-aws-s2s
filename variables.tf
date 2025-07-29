# =============================================================================
# Variables for AWS Site-to-Site Connectivity Module
# =============================================================================

# =============================================================================
# General Configuration
# =============================================================================

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.aws_region))
    error_message = "AWS region must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "name_prefix" {
  description = "Prefix to be used for resource naming"
  type        = string
  default     = "s2s"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.name_prefix))
    error_message = "Name prefix must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default = {
    Environment = "production"
    Project     = "site-to-site-connectivity"
    ManagedBy   = "terraform"
  }
}

# =============================================================================
# VPC Configuration
# =============================================================================

variable "create_vpc" {
  description = "Whether to create a new VPC"
  type        = bool
  default     = true
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr_block, 0))
    error_message = "VPC CIDR block must be a valid IPv4 CIDR block."
  }
}

variable "vpc_secondary_cidr_blocks" {
  description = "List of secondary CIDR blocks for the VPC"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for cidr in var.vpc_secondary_cidr_blocks : can(cidrhost(cidr, 0))
    ])
    error_message = "All secondary CIDR blocks must be valid IPv4 CIDR blocks."
  }
}

variable "enable_dns_hostnames" {
  description = "Whether to enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Whether to enable DNS support in the VPC"
  type        = bool
  default     = true
}

# =============================================================================
# Subnet Configuration
# =============================================================================

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]

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
  default     = ["10.0.101.0/24", "10.0.102.0/24"]

  validation {
    condition = alltrue([
      for cidr in var.public_subnet_cidrs : can(cidrhost(cidr, 0))
    ])
    error_message = "All public subnet CIDR blocks must be valid IPv4 CIDR blocks."
  }
}

variable "map_public_ip_on_launch" {
  description = "Whether to map public IP on launch for public subnets"
  type        = bool
  default     = true
}

# =============================================================================
# Internet Gateway Configuration
# =============================================================================

variable "create_internet_gateway" {
  description = "Whether to create an Internet Gateway"
  type        = bool
  default     = true
}

# =============================================================================
# NAT Gateway Configuration
# =============================================================================

variable "create_nat_gateways" {
  description = "Whether to create NAT Gateways"
  type        = bool
  default     = true
}

# =============================================================================
# VPN Configuration
# =============================================================================

variable "create_vpn_gateway" {
  description = "Whether to create a VPN Gateway"
  type        = bool
  default     = false
}

variable "customer_gateways" {
  description = "Map of customer gateway configurations"
  type = map(object({
    bgp_asn    = number
    ip_address = string
  }))
  default = {}

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
    tunnel1_inside_ipv6_cidr  = optional(string)
    tunnel2_inside_ipv6_cidr  = optional(string)
  }))
  default = {}
}

variable "vpn_routes" {
  description = "Map of VPN route configurations"
  type = map(object({
    destination_cidr_block = string
    vpn_connection_key     = string
  }))
  default = {}
}

variable "create_vpn_security_group" {
  description = "Whether to create a security group for VPN traffic"
  type        = bool
  default     = false
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
      description = "IKE"
    },
    {
      from_port   = 4500
      to_port     = 4500
      protocol    = "udp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "NAT-T"
    }
  ]
}

variable "create_vpn_logs" {
  description = "Whether to create CloudWatch log group for VPN logs"
  type        = bool
  default     = false
}

variable "vpn_log_retention_days" {
  description = "Number of days to retain VPN logs"
  type        = number
  default     = 30

  validation {
    condition     = var.vpn_log_retention_days >= 1 && var.vpn_log_retention_days <= 3653
    error_message = "VPN log retention days must be between 1 and 3653."
  }
}

variable "create_vpn_monitoring_role" {
  description = "Whether to create IAM role for VPN monitoring"
  type        = bool
  default     = false
}

# =============================================================================
# Direct Connect Configuration
# =============================================================================

variable "create_direct_connect_gateway" {
  description = "Whether to create a Direct Connect Gateway"
  type        = bool
  default     = false
}

variable "dx_gateway_amazon_side_asn" {
  description = "Amazon side ASN for Direct Connect Gateway"
  type        = number
  default     = 64512

  validation {
    condition     = var.dx_gateway_amazon_side_asn >= 64512 && var.dx_gateway_amazon_side_asn <= 65534
    error_message = "Direct Connect Gateway Amazon side ASN must be between 64512 and 65534."
  }
}

variable "dx_allowed_prefixes" {
  description = "List of allowed prefixes for Direct Connect Gateway"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for prefix in var.dx_allowed_prefixes : can(cidrhost(prefix, 0))
    ])
    error_message = "All Direct Connect allowed prefixes must be valid IPv4 CIDR blocks."
  }
}

# =============================================================================
# Transit Gateway Configuration
# =============================================================================

variable "create_transit_gateway" {
  description = "Whether to create a Transit Gateway"
  type        = bool
  default     = false
}

variable "transit_gateway_amazon_side_asn" {
  description = "Amazon side ASN for Transit Gateway"
  type        = number
  default     = 64512

  validation {
    condition     = var.transit_gateway_amazon_side_asn >= 64512 && var.transit_gateway_amazon_side_asn <= 65534
    error_message = "Transit Gateway Amazon side ASN must be between 64512 and 65534."
  }
}

variable "transit_gateway_auto_accept_shared_attachments" {
  description = "Whether to auto accept shared attachments for Transit Gateway"
  type        = bool
  default     = false
}

variable "transit_gateway_default_route_table_association" {
  description = "Whether to enable default route table association for Transit Gateway"
  type        = bool
  default     = true
}

variable "transit_gateway_default_route_table_propagation" {
  description = "Whether to enable default route table propagation for Transit Gateway"
  type        = bool
  default     = true
}

variable "transit_gateway_dns_support" {
  description = "Whether to enable DNS support for Transit Gateway"
  type        = bool
  default     = true
}

variable "transit_gateway_vpn_ecmp_support" {
  description = "Whether to enable VPN ECMP support for Transit Gateway"
  type        = bool
  default     = true
}

variable "transit_gateway_vpc_attachment_default_route_table_association" {
  description = "Whether to enable default route table association for Transit Gateway VPC attachment"
  type        = bool
  default     = true
}

variable "transit_gateway_vpc_attachment_default_route_table_propagation" {
  description = "Whether to enable default route table propagation for Transit Gateway VPC attachment"
  type        = bool
  default     = true
} 