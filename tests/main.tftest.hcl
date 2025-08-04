# =============================================================================
# Terraform Tests for AWS Site-to-Site Connectivity Module
# =============================================================================

variables {
  name_prefix          = "test-s2s"
  vpc_cidr_block      = "10.0.0.0/16"
  private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24"]
  create_vpc          = true
  create_vpn_gateway  = true
  
  customer_gateways = {
    test_cgw = {
      bgp_asn    = 65000
      ip_address = "203.0.113.1"
    }
  }
  
  vpn_connections = {
    test_connection = {
      customer_gateway_key = "test_cgw"
      static_routes_only   = false
    }
  }
}

# Test VPC Creation
run "verify_vpc_creation" {
  command = plan

  assert {
    condition     = var.create_vpc ? length(aws_vpc.main) == 1 : length(aws_vpc.main) == 0
    error_message = "VPC creation does not match create_vpc variable"
  }

  assert {
    condition     = var.create_vpc ? aws_vpc.main[0].cidr_block == var.vpc_cidr_block : true
    error_message = "VPC CIDR block does not match specified value"
  }

  assert {
    condition     = var.create_vpc ? aws_vpc.main[0].enable_dns_hostnames == var.enable_dns_hostnames : true
    error_message = "DNS hostnames setting does not match"
  }
}

# Test Subnet Creation
run "verify_subnet_count" {
  command = plan

  assert {
    condition     = length(aws_subnet.private) == length(var.private_subnet_cidrs)
    error_message = "Incorrect number of private subnets created. Expected ${length(var.private_subnet_cidrs)}, got ${length(aws_subnet.private)}"
  }

  assert {
    condition     = length(aws_subnet.public) == length(var.public_subnet_cidrs)
    error_message = "Incorrect number of public subnets created. Expected ${length(var.public_subnet_cidrs)}, got ${length(aws_subnet.public)}"
  }
}

# Test Route Tables
run "verify_route_tables" {
  command = plan

  assert {
    condition     = var.create_vpc && var.create_nat_gateways ? length(aws_route_table.private) == length(var.private_subnet_cidrs) : true
    error_message = "Incorrect number of private route tables created"
  }

  assert {
    condition     = var.create_vpc ? length(aws_route_table.public) == 1 : true
    error_message = "Public route table should be created when VPC is created"
  }
}

# Test VPN Gateway
run "verify_vpn_gateway" {
  command = plan

  assert {
    condition     = var.create_vpn_gateway ? length(aws_vpn_gateway.main) == 1 : length(aws_vpn_gateway.main) == 0
    error_message = "VPN Gateway creation does not match create_vpn_gateway variable"
  }

  assert {
    condition     = var.create_vpn_gateway ? aws_vpn_gateway.main[0].amazon_side_asn == var.vpn_gateway_amazon_side_asn : true
    error_message = "VPN Gateway ASN does not match specified value"
  }
}

# Test Customer Gateways
run "verify_customer_gateways" {
  command = plan

  assert {
    condition     = length(aws_customer_gateway.main) == length(var.customer_gateways)
    error_message = "Number of customer gateways does not match configuration"
  }
}

# Test VPN Connections
run "verify_vpn_connections" {
  command = plan

  assert {
    condition     = length(aws_vpn_connection.main) == length(var.vpn_connections)
    error_message = "Number of VPN connections does not match configuration"
  }
}

# Test Resource Tagging
run "verify_resource_tagging" {
  command = plan

  assert {
    condition = var.create_vpc ? contains(keys(aws_vpc.main[0].tags), "terraform-module") : true
    error_message = "VPC should have terraform-module tag"
  }

  assert {
    condition = var.create_vpc ? aws_vpc.main[0].tags["terraform-module"] == "tfm-aws-s2s" : true
    error_message = "VPC terraform-module tag should be 'tfm-aws-s2s'"
  }
}

# Integration Test (Apply and Destroy)
run "integration_test" {
  command = apply

  variables {
    name_prefix    = "integration-test"
    create_vpc     = true
    vpc_cidr_block = "10.99.0.0/16"
    private_subnet_cidrs = ["10.99.1.0/24"]
    public_subnet_cidrs  = ["10.99.101.0/24"]
    create_nat_gateways = false  # Reduce costs for testing
    create_vpn_gateway  = false  # Skip VPN for basic integration test
  }

  assert {
    condition     = aws_vpc.main[0].state == "available"
    error_message = "VPC should be in available state after creation"
  }

  assert {
    condition     = length(aws_subnet.private) > 0
    error_message = "At least one private subnet should be created"
  }
}

# Test Security Group Creation
run "verify_security_groups" {
  command = plan

  variables {
    create_vpn_security_group = true
  }

  assert {
    condition     = var.create_vpn_security_group ? length(aws_security_group.vpn) == 1 : length(aws_security_group.vpn) == 0
    error_message = "VPN security group creation does not match create_vpn_security_group variable"
  }
}

# Test CloudWatch Resources
run "verify_cloudwatch_resources" {
  command = plan

  variables {
    create_vpn_logs = true
    create_cloudwatch_alarms = true
    cloudwatch_alarms = {
      test_alarm = {
        alarm_name          = "test-alarm"
        comparison_operator = "GreaterThanThreshold"
        evaluation_periods  = 2
        metric_name         = "TestMetric"
        namespace           = "AWS/Test"
        period              = 300
        statistic           = "Average"
        threshold           = 1
      }
    }
  }

  assert {
    condition     = var.create_vpn_logs ? length(aws_cloudwatch_log_group.vpn) == 1 : length(aws_cloudwatch_log_group.vpn) == 0
    error_message = "CloudWatch log group creation does not match create_vpn_logs variable"
  }

  assert {
    condition     = var.create_cloudwatch_alarms ? length(aws_cloudwatch_metric_alarm.main) == length(var.cloudwatch_alarms) : true
    error_message = "CloudWatch alarms creation does not match configuration"
  }
}
