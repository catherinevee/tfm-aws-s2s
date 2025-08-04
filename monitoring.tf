# =============================================================================
# Enhanced Monitoring and Alerting
# =============================================================================

# SNS Topic for alerts
resource "aws_sns_topic" "connectivity_alerts" {
  count = var.create_connectivity_alerts ? 1 : 0

  name = "${var.name_prefix}-connectivity-alerts"

  tags = merge(
    var.common_tags,
    {
      Name = "${var.name_prefix}-connectivity-alerts"
    }
  )
}

# CloudWatch Dashboard for connectivity monitoring
resource "aws_cloudwatch_dashboard" "connectivity" {
  count = var.create_monitoring_dashboard ? 1 : 0

  dashboard_name = "${var.name_prefix}-connectivity-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/VPN", "TunnelState", "VpnId", aws_vpn_connection.main["primary"].id],
            [".", "TunnelDataIn", ".", "."],
            [".", "TunnelDataOut", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "VPN Connection Metrics"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/EC2", "NetworkIn", "InstanceId", "*"],
            [".", "NetworkOut", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "EC2 Network Metrics"
          period  = 300
        }
      }
    ]
  })
}

# Enhanced VPN Connection Health Checks
resource "aws_cloudwatch_metric_alarm" "vpn_tunnel_down" {
  for_each = var.create_vpn_gateway ? var.vpn_connections : {}

  alarm_name          = "${var.name_prefix}-vpn-${each.key}-tunnel-down"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "TunnelState"
  namespace           = "AWS/VPN"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "This metric monitors VPN tunnel state for ${each.key}"
  alarm_actions       = var.create_connectivity_alerts ? [aws_sns_topic.connectivity_alerts[0].arn] : []

  dimensions = {
    VpnId = aws_vpn_connection.main[each.key].id
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.name_prefix}-vpn-${each.key}-tunnel-alarm"
    }
  )
}

# Network Performance Monitoring
resource "aws_cloudwatch_metric_alarm" "nat_gateway_bandwidth" {
  count = var.create_vpc && var.create_nat_gateways && var.enable_nat_gateway_monitoring ? length(var.public_subnet_cidrs) : 0

  alarm_name          = "${var.name_prefix}-nat-gateway-${count.index + 1}-bandwidth"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "BytesOutToDestination"
  namespace           = "AWS/NATGateway"
  period              = "300"
  statistic           = "Sum"
  threshold           = var.nat_gateway_bandwidth_threshold
  alarm_description   = "This metric monitors NAT Gateway bandwidth usage"
  alarm_actions       = var.create_connectivity_alerts ? [aws_sns_topic.connectivity_alerts[0].arn] : []

  dimensions = {
    NatGatewayId = aws_nat_gateway.main[count.index].id
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.name_prefix}-nat-gateway-${count.index + 1}-bandwidth-alarm"
    }
  )
}

# Custom Metric for Connection Health Score
resource "aws_cloudwatch_log_metric_filter" "connection_health" {
  count = var.create_vpn_logs && var.enable_connection_health_metrics ? 1 : 0

  name           = "${var.name_prefix}-connection-health"
  log_group_name = aws_cloudwatch_log_group.vpn[0].name
  pattern        = "[timestamp, request_id, status=\"CONNECTED\", ...]"

  metric_transformation {
    name      = "ConnectionHealth"
    namespace = "Custom/Connectivity"
    value     = "1"
  }
}
