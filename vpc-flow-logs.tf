# =============================================================================
# VPC Flow Logs
# =============================================================================

resource "aws_flow_log" "vpc_flow_log" {
  count = var.create_vpc && var.enable_vpc_flow_logs ? 1 : 0

  iam_role_arn    = aws_iam_role.flow_log[0].arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_log[0].arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main[0].id

  # Enhanced Flow Log Configuration
  log_format                   = var.vpc_flow_log_format
  max_aggregation_interval     = var.vpc_flow_log_max_aggregation_interval
  log_destination_type         = "cloud-watch-logs"
  deliver_cross_account_role   = var.vpc_flow_log_cross_account_role

  tags = merge(
    var.common_tags,
    var.vpc_flow_log_tags,
    {
      Name = "${var.name_prefix}-vpc-flow-log"
    }
  )
}

resource "aws_cloudwatch_log_group" "vpc_flow_log" {
  count = var.create_vpc && var.enable_vpc_flow_logs ? 1 : 0

  name              = "/aws/vpc/flowlogs/${var.name_prefix}"
  retention_in_days = var.vpc_flow_log_retention_days
  kms_key_id        = var.vpc_flow_log_kms_key_id

  tags = merge(
    var.common_tags,
    var.vpc_flow_log_tags,
    {
      Name = "${var.name_prefix}-vpc-flow-log-group"
    }
  )
}

resource "aws_iam_role" "flow_log" {
  count = var.create_vpc && var.enable_vpc_flow_logs ? 1 : 0

  name = "${var.name_prefix}-vpc-flow-log-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.common_tags,
    {
      Name = "${var.name_prefix}-vpc-flow-log-role"
    }
  )
}

resource "aws_iam_role_policy" "flow_log" {
  count = var.create_vpc && var.enable_vpc_flow_logs ? 1 : 0

  name = "${var.name_prefix}-vpc-flow-log-policy"
  role = aws_iam_role.flow_log[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "*"
      }
    ]
  })
}
