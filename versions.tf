# =============================================================================
# Terraform and Provider Versions
# =============================================================================

terraform {
  required_version = ">= 1.13.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.12"
    }
  }

  # Add experimental features if needed
  experiments = []
}

# =============================================================================
# Provider Configuration
# =============================================================================

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = merge(
      var.common_tags,
      {
        "terraform-module"        = "tfm-aws-s2s"
        "terraform-version"       = "1.13.0"
        "aws-provider-version"    = "6.2.0"
        "module-version"          = "2.0.0"
        "last-modified"           = timestamp()
      }
    )
  }

  # Enhanced provider configuration
  retry_mode = "adaptive"
  max_retries = 3

  # Conditional assume role configuration
  # assume_role {
  #   role_arn = var.assume_role_arn  # Add this variable if cross-account access is needed
  # }

  # Add provider endpoints configuration for specific use cases (e.g., VPC endpoints)
  # endpoints {
  #   ec2 = var.ec2_endpoint  # Add this variable if custom EC2 endpoint is needed
  #   iam = var.iam_endpoint  # Add this variable if custom IAM endpoint is needed
  #   logs = var.logs_endpoint  # Add this variable if custom CloudWatch Logs endpoint is needed
  # }
} 