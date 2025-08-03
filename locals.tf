# =============================================================================
# Local Variables
# =============================================================================

locals {
  # VPC and Networking
  vpc_id = var.create_vpc ? aws_vpc.main[0].id : var.existing_vpc_id
  
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
    }
  )
}
