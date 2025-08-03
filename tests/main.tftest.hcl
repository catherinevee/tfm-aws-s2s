variables {
  name_prefix        = "test-s2s"
  vpc_cidr_block     = "10.0.0.0/16"
  private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24"]
  create_vpc         = true
  enable_vpc_flow_logs = true
}

run "verify_vpc_creation" {
  command = plan

  assert {
    condition     = length(aws_vpc.main) > 0
    error_message = "VPC was not created"
  }
}

run "verify_subnet_count" {
  command = plan

  assert {
    condition     = length(aws_subnet.private) == length(var.private_subnet_cidrs)
    error_message = "Incorrect number of private subnets created"
  }
}

run "verify_flow_logs" {
  command = plan

  assert {
    condition     = var.enable_vpc_flow_logs ? length(aws_flow_log.vpc_flow_log) > 0 : true
    error_message = "VPC Flow Logs were not created when enabled"
  }
}

run "verify_route_tables" {
  command = plan

  assert {
    condition     = length(aws_route_table.private) == length(var.private_subnet_cidrs)
    error_message = "Incorrect number of private route tables created"
  }
}
