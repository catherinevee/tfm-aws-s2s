# =============================================================================
# Monitoring and Alerting Variables
# =============================================================================

variable "create_connectivity_alerts" {
  description = "Whether to create SNS topic and CloudWatch alarms for connectivity monitoring"
  type        = bool
  default     = false
}

variable "create_monitoring_dashboard" {
  description = "Whether to create a CloudWatch dashboard for connectivity monitoring"
  type        = bool
  default     = false
}

variable "enable_nat_gateway_monitoring" {
  description = "Whether to enable CloudWatch alarms for NAT Gateway bandwidth monitoring"
  type        = bool
  default     = false
}

variable "nat_gateway_bandwidth_threshold" {
  description = "Threshold in bytes for NAT Gateway bandwidth alarm"
  type        = number
  default     = 1000000000  # 1GB

  validation {
    condition     = var.nat_gateway_bandwidth_threshold > 0
    error_message = "NAT Gateway bandwidth threshold must be greater than 0."
  }
}

variable "enable_connection_health_metrics" {
  description = "Whether to enable custom connection health metrics from VPN logs"
  type        = bool
  default     = false
}

variable "connectivity_alert_email" {
  description = "Email address for connectivity alerts (optional)"
  type        = string
  default     = null

  validation {
    condition     = var.connectivity_alert_email == null || can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.connectivity_alert_email))
    error_message = "If provided, connectivity alert email must be a valid email address."
  }
}
