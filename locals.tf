# =============================================================================
# Local Variables
# =============================================================================

locals {
  # VPC and Networking
  vpc_id = var.create_vpc ? aws_vpc.main[0].id : null
  
  # Resource Naming
  resource_names = {
    vpc                = "${var.name_prefix}-vpc"
    private_subnet     = "${var.name_prefix}-private"
    public_subnet      = "${var.name_prefix}-public"
    vpn_gateway       = "${var.name_prefix}-vgw"
    customer_gateway   = "${var.name_prefix}-cgw"
    transit_gateway    = "${var.name_prefix}-tgw"
    dx_gateway        = "${var.name_prefix}-dxgw"
  }

  # Tag Management
  common_tags = merge(
    var.common_tags,
    {
      "terraform-module" = "tfm-aws-s2s"
      "terraform-version" = "1.13.0"
      "aws-provider-version" = "6.2.0"
    }
  )

  # Availability Zone mapping for consistent resource distribution
  az_count = length(data.aws_availability_zones.available.names)
  
  # Subnet configuration helpers
  private_subnet_count = length(var.private_subnet_cidrs)
  public_subnet_count = length(var.public_subnet_cidrs)
  
  # Validation helpers
  subnet_az_mapping = {
    for i, cidr in var.private_subnet_cidrs : i => {
      cidr              = cidr
      availability_zone = data.aws_availability_zones.available.names[i % local.az_count]
    }
  }
}
