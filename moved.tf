# =============================================================================
# Moved Blocks for Resource Refactoring
# =============================================================================
# These moved blocks help with state migration when resources are renamed
# or restructured to maintain backward compatibility.

# Example moved blocks for future resource refactoring
# Uncomment and modify as needed when resources are restructured

# moved {
#   from = aws_vpc.vpc
#   to   = aws_vpc.main
# }

# moved {
#   from = aws_subnet.private_subnet
#   to   = aws_subnet.private
# }

# moved {
#   from = aws_subnet.public_subnet
#   to   = aws_subnet.public
# }
