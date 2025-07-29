# AWS Site-to-Site Connectivity Module

A comprehensive Terraform module for designing routing strategy and connectivity architecture between on-premises networks and AWS Cloud. This module provides multiple connectivity options including VPN, Direct Connect, and Transit Gateway solutions.

## Features

- **Multi-Connectivity Options**: Support for VPN, Direct Connect, and Transit Gateway
- **Flexible VPC Design**: Configurable VPC with public and private subnets
- **High Availability**: Multi-AZ deployment with redundant connectivity
- **Security**: Built-in security groups and IAM roles
- **Monitoring**: CloudWatch logging and monitoring capabilities
- **Modular Design**: Reusable components for different deployment scenarios

## Architecture

This module supports the following connectivity patterns:

1. **Site-to-Site VPN**: IPsec VPN connections between on-premises and AWS
2. **Direct Connect**: Dedicated network connections for high bandwidth and low latency
3. **Transit Gateway**: Centralized hub for connecting multiple VPCs and on-premises networks
4. **Hybrid Solutions**: Combinations of the above for redundancy and performance

## Usage

### Basic VPN Setup

```hcl
module "site_to_site" {
  source = "./tfm-aws-s2s"

  name_prefix = "my-vpn"
  aws_region  = "us-east-1"

  # VPC Configuration
  vpc_cidr_block        = "10.0.0.0/16"
  private_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnet_cidrs   = ["10.0.101.0/24", "10.0.102.0/24"]

  # VPN Configuration
  create_vpn_gateway = true
  customer_gateways = {
    primary = {
      bgp_asn    = 65000
      ip_address = "203.0.113.1"
    }
    secondary = {
      bgp_asn    = 65001
      ip_address = "203.0.113.2"
    }
  }

  vpn_connections = {
    primary = {
      customer_gateway_key = "primary"
      static_routes_only   = false
    }
    secondary = {
      customer_gateway_key = "secondary"
      static_routes_only   = false
    }
  }

  vpn_routes = {
    on_premises_network = {
      destination_cidr_block = "192.168.0.0/16"
      vpn_connection_key     = "primary"
    }
  }

  common_tags = {
    Environment = "production"
    Project     = "hybrid-cloud"
    Owner       = "network-team"
  }
}
```

### Direct Connect Setup

```hcl
module "site_to_site" {
  source = "./tfm-aws-s2s"

  name_prefix = "my-dx"
  aws_region  = "us-east-1"

  # VPC Configuration
  vpc_cidr_block        = "10.0.0.0/16"
  private_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnet_cidrs   = ["10.0.101.0/24", "10.0.102.0/24"]

  # Direct Connect Configuration
  create_direct_connect_gateway = true
  dx_gateway_amazon_side_asn    = 64512
  dx_allowed_prefixes          = ["192.168.0.0/16", "172.16.0.0/12"]

  common_tags = {
    Environment = "production"
    Project     = "enterprise-connectivity"
  }
}
```

### Transit Gateway Setup

```hcl
module "site_to_site" {
  source = "./tfm-aws-s2s"

  name_prefix = "my-tgw"
  aws_region  = "us-east-1"

  # VPC Configuration
  vpc_cidr_block        = "10.0.0.0/16"
  private_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnet_cidrs   = ["10.0.101.0/24", "10.0.102.0/24"]

  # Transit Gateway Configuration
  create_transit_gateway = true
  transit_gateway_amazon_side_asn = 64512

  # VPN Configuration for Transit Gateway
  create_vpn_gateway = true
  customer_gateways = {
    primary = {
      bgp_asn    = 65000
      ip_address = "203.0.113.1"
    }
  }

  vpn_connections = {
    primary = {
      customer_gateway_key = "primary"
      static_routes_only   = false
    }
  }

  common_tags = {
    Environment = "production"
    Project     = "multi-vpc-hub"
  }
}
```

### Advanced Hybrid Setup

```hcl
module "site_to_site" {
  source = "./tfm-aws-s2s"

  name_prefix = "hybrid-advanced"
  aws_region  = "us-east-1"

  # VPC Configuration with multiple CIDR blocks
  vpc_cidr_block              = "10.0.0.0/16"
  vpc_secondary_cidr_blocks   = ["10.1.0.0/16", "10.2.0.0/16"]
  private_subnet_cidrs        = ["10.0.1.0/24", "10.0.2.0/24", "10.1.1.0/24", "10.1.2.0/24"]
  public_subnet_cidrs         = ["10.0.101.0/24", "10.0.102.0/24"]

  # Transit Gateway
  create_transit_gateway = true
  transit_gateway_amazon_side_asn = 64512

  # VPN Configuration
  create_vpn_gateway = true
  customer_gateways = {
    primary = {
      bgp_asn    = 65000
      ip_address = "203.0.113.1"
    }
    secondary = {
      bgp_asn    = 65001
      ip_address = "203.0.113.2"
    }
  }

  vpn_connections = {
    primary = {
      customer_gateway_key = "primary"
      static_routes_only   = false
    }
    secondary = {
      customer_gateway_key = "secondary"
      static_routes_only   = false
    }
  }

  # Direct Connect
  create_direct_connect_gateway = true
  dx_gateway_amazon_side_asn    = 64512
  dx_allowed_prefixes          = ["192.168.0.0/16"]

  # Security and Monitoring
  create_vpn_security_group = true
  create_vpn_logs          = true
  create_vpn_monitoring_role = true

  vpn_security_group_rules = [
    {
      from_port   = 500
      to_port     = 500
      protocol    = "udp"
      cidr_blocks = ["203.0.113.0/24"]
      description = "IKE from on-premises"
    },
    {
      from_port   = 4500
      to_port     = 4500
      protocol    = "udp"
      cidr_blocks = ["203.0.113.0/24"]
      description = "NAT-T from on-premises"
    }
  ]

  common_tags = {
    Environment = "production"
    Project     = "enterprise-hybrid"
    CostCenter  = "network-infrastructure"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 5.0 |

## Inputs

### General Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws_region | AWS region to deploy resources | `string` | `"us-east-1"` | no |
| name_prefix | Prefix to be used for resource naming | `string` | `"s2s"` | no |
| common_tags | Common tags to be applied to all resources | `map(string)` | `{"Environment"="production","ManagedBy"="terraform","Project"="site-to-site-connectivity"}` | no |

### VPC Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| create_vpc | Whether to create a new VPC | `bool` | `true` | no |
| vpc_cidr_block | CIDR block for the VPC | `string` | `"10.0.0.0/16"` | no |
| vpc_secondary_cidr_blocks | List of secondary CIDR blocks for the VPC | `list(string)` | `[]` | no |
| enable_dns_hostnames | Whether to enable DNS hostnames in the VPC | `bool` | `true` | no |
| enable_dns_support | Whether to enable DNS support in the VPC | `bool` | `true` | no |

### Subnet Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| private_subnet_cidrs | List of CIDR blocks for private subnets | `list(string)` | `["10.0.1.0/24","10.0.2.0/24"]` | no |
| public_subnet_cidrs | List of CIDR blocks for public subnets | `list(string)` | `["10.0.101.0/24","10.0.102.0/24"]` | no |
| map_public_ip_on_launch | Whether to map public IP on launch for public subnets | `bool` | `true` | no |

### VPN Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| create_vpn_gateway | Whether to create a VPN Gateway | `bool` | `false` | no |
| customer_gateways | Map of customer gateway configurations | `map(object)` | `{}` | no |
| vpn_connections | Map of VPN connection configurations | `map(object)` | `{}` | no |
| vpn_routes | Map of VPN route configurations | `map(object)` | `{}` | no |
| create_vpn_security_group | Whether to create a security group for VPN traffic | `bool` | `false` | no |
| create_vpn_logs | Whether to create CloudWatch log group for VPN logs | `bool` | `false` | no |
| create_vpn_monitoring_role | Whether to create IAM role for VPN monitoring | `bool` | `false` | no |

### Direct Connect Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| create_direct_connect_gateway | Whether to create a Direct Connect Gateway | `bool` | `false` | no |
| dx_gateway_amazon_side_asn | Amazon side ASN for Direct Connect Gateway | `number` | `64512` | no |
| dx_allowed_prefixes | List of allowed prefixes for Direct Connect Gateway | `list(string)` | `[]` | no |

### Transit Gateway Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| create_transit_gateway | Whether to create a Transit Gateway | `bool` | `false` | no |
| transit_gateway_amazon_side_asn | Amazon side ASN for Transit Gateway | `number` | `64512` | no |
| transit_gateway_auto_accept_shared_attachments | Whether to auto accept shared attachments for Transit Gateway | `bool` | `false` | no |
| transit_gateway_default_route_table_association | Whether to enable default route table association for Transit Gateway | `bool` | `true` | no |
| transit_gateway_default_route_table_propagation | Whether to enable default route table propagation for Transit Gateway | `bool` | `true` | no |
| transit_gateway_dns_support | Whether to enable DNS support for Transit Gateway | `bool` | `true` | no |
| transit_gateway_vpn_ecmp_support | Whether to enable VPN ECMP support for Transit Gateway | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | ID of the VPC |
| vpc_cidr_block | CIDR block of the VPC |
| private_subnet_ids | IDs of the private subnets |
| public_subnet_ids | IDs of the public subnets |
| vpn_gateway_id | ID of the VPN Gateway |
| customer_gateway_ids | IDs of the Customer Gateways |
| vpn_connection_ids | IDs of the VPN Connections |
| direct_connect_gateway_id | ID of the Direct Connect Gateway |
| transit_gateway_id | ID of the Transit Gateway |
| connectivity_summary | Summary of connectivity resources created |

## Examples

See the `examples/` directory for complete working examples:

- `examples/basic-vpn/` - Basic VPN setup
- `examples/direct-connect/` - Direct Connect setup
- `examples/transit-gateway/` - Transit Gateway setup
- `examples/hybrid-advanced/` - Advanced hybrid setup

## Best Practices

### Security

1. **Network Segmentation**: Use private subnets for sensitive workloads
2. **Security Groups**: Implement least-privilege access with security groups
3. **Encryption**: Enable encryption for all data in transit
4. **Monitoring**: Use CloudWatch logs and monitoring for visibility

### High Availability

1. **Multi-AZ Deployment**: Deploy resources across multiple availability zones
2. **Redundant Connections**: Use multiple VPN tunnels or Direct Connect connections
3. **Failover Testing**: Regularly test failover scenarios

### Cost Optimization

1. **NAT Gateway Placement**: Use one NAT Gateway per AZ for cost efficiency
2. **Resource Tagging**: Implement comprehensive tagging for cost tracking
3. **Right-sizing**: Choose appropriate instance types and bandwidth

### Operational Excellence

1. **Documentation**: Maintain up-to-date network documentation
2. **Change Management**: Use Terraform workspaces for environment separation
3. **Monitoring**: Set up alerts for connectivity issues
4. **Backup**: Regularly backup Terraform state and configurations

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This module is licensed under the MIT License. See LICENSE file for details.

## Support

For issues and questions:

1. Check the [documentation](https://registry.terraform.io/modules/your-org/aws-s2s)
2. Search existing [issues](https://github.com/your-org/tfm-aws-s2s/issues)
3. Create a new issue with detailed information

## Roadmap

- [ ] Support for IPv6
- [ ] Integration with AWS Network Firewall
- [ ] Support for AWS Site-to-Site VPN with Transit Gateway
- [ ] Enhanced monitoring and alerting
- [ ] Integration with AWS Config for compliance