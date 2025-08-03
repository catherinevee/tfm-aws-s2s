# =============================================================================
# Routing Configuration
# =============================================================================

# Route Tables
resource "aws_route_table" "private" {
  count = var.create_vpc ? length(var.private_subnet_cidrs) : 0

  vpc_id = local.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.resource_names.private_subnet}-rt-${count.index + 1}"
      Tier = "Private"
    }
  )
}

resource "aws_route_table" "public" {
  count = var.create_vpc ? length(var.public_subnet_cidrs) : 0

  vpc_id = local.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.resource_names.public_subnet}-rt-${count.index + 1}"
      Tier = "Public"
    }
  )
}

# Route Table Associations
resource "aws_route_table_association" "private" {
  count = var.create_vpc ? length(var.private_subnet_cidrs) : 0

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_route_table_association" "public" {
  count = var.create_vpc ? length(var.public_subnet_cidrs) : 0

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[count.index].id
}

# VPN Routes
resource "aws_route" "vpn_routes" {
  for_each = var.vpn_routes

  route_table_id         = aws_route_table.private[0].id
  destination_cidr_block = each.value.destination_cidr_block
  gateway_id            = aws_vpn_gateway.main[0].id

  depends_on = [aws_route_table.private]
}
