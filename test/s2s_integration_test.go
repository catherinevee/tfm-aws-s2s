package test

import (
	"fmt"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// TestS2SBasicVPN tests the basic Site-to-Site VPN functionality
func TestS2SBasicVPN(t *testing.T) {
	t.Parallel()

	// Generate a random name prefix to avoid naming conflicts
	namePrefix := fmt.Sprintf("test-s2s-%s", strings.ToLower(random.UniqueId()))
	awsRegion := "us-east-1"

	// Terraform configuration
	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/basic-vpn",
		Vars: map[string]interface{}{
			"name_prefix":          namePrefix,
			"aws_region":           awsRegion,
			"create_vpc":           true,
			"vpc_cidr_block":       "10.0.0.0/16",
			"private_subnet_cidrs": []string{"10.0.1.0/24", "10.0.2.0/24"},
			"public_subnet_cidrs":  []string{"10.0.101.0/24", "10.0.102.0/24"},
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
		RetryableTerraformErrors: map[string]string{
			".*": "Retrying due to transient error",
		},
		MaxRetries:         3,
		TimeBetweenRetries: 5 * time.Second,
	}

	// Clean up resources with "terraform destroy" at the end of the test
	defer terraform.Destroy(t, terraformOptions)

	// Run "terraform init" and "terraform apply"
	terraform.InitAndApply(t, terraformOptions)

	// Validate the outputs
	vpcId := terraform.Output(t, terraformOptions, "vpc_id")
	privateSubnetIds := terraform.OutputList(t, terraformOptions, "private_subnet_ids")
	publicSubnetIds := terraform.OutputList(t, terraformOptions, "public_subnet_ids")

	// Assertions
	require.NotEmpty(t, vpcId, "VPC ID should not be empty")
	assert.Len(t, privateSubnetIds, 2, "Should create 2 private subnets")
	assert.Len(t, publicSubnetIds, 2, "Should create 2 public subnets")

	// Validate AWS resources exist
	vpc := aws.GetVpcById(t, vpcId, awsRegion)
	assert.Equal(t, "10.0.0.0/16", vpc.CidrBlock, "VPC CIDR should match expected value")

	// Validate subnets are in different AZs for high availability
	privateSubnets := aws.GetSubnetsForVpc(t, vpcId, awsRegion)
	azs := make(map[string]bool)
	for _, subnet := range privateSubnets {
		azs[subnet.AvailabilityZone] = true
	}
	assert.GreaterOrEqual(t, len(azs), 2, "Subnets should be distributed across multiple AZs")
}

// TestS2STransitGateway tests Transit Gateway functionality
func TestS2STransitGateway(t *testing.T) {
	t.Parallel()

	namePrefix := fmt.Sprintf("test-tgw-%s", strings.ToLower(random.UniqueId()))
	awsRegion := "us-west-2"

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/transit-gateway",
		Vars: map[string]interface{}{
			"name_prefix":                     namePrefix,
			"aws_region":                      awsRegion,
			"create_transit_gateway":          true,
			"transit_gateway_amazon_side_asn": 64512,
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
		RetryableTerraformErrors: map[string]string{
			".*": "Retrying due to transient error",
		},
		MaxRetries:         3,
		TimeBetweenRetries: 10 * time.Second,
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Validate Transit Gateway outputs
	tgwId := terraform.Output(t, terraformOptions, "transit_gateway_id")
	tgwArn := terraform.Output(t, terraformOptions, "transit_gateway_arn")

	require.NotEmpty(t, tgwId, "Transit Gateway ID should not be empty")
	require.NotEmpty(t, tgwArn, "Transit Gateway ARN should not be empty")
	assert.Contains(t, tgwArn, tgwId, "ARN should contain the Transit Gateway ID")
}

// TestS2SVPCFlowLogs tests VPC Flow Logs functionality
func TestS2SVPCFlowLogs(t *testing.T) {
	t.Parallel()

	namePrefix := fmt.Sprintf("test-flow-%s", strings.ToLower(random.UniqueId()))
	awsRegion := "us-east-1"

	terraformOptions := &terraform.Options{
		TerraformDir: "../",
		Vars: map[string]interface{}{
			"name_prefix":                 namePrefix,
			"aws_region":                  awsRegion,
			"create_vpc":                  true,
			"enable_vpc_flow_logs":        true,
			"vpc_flow_log_retention_days": 7,
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Validate VPC Flow Logs
	vpcId := terraform.Output(t, terraformOptions, "vpc_id")
	require.NotEmpty(t, vpcId, "VPC ID should not be empty")

	// Check if flow logs are enabled for the VPC
	flowLogs := aws.GetVpcFlowLogs(t, vpcId, awsRegion)
	assert.NotEmpty(t, flowLogs, "VPC should have flow logs enabled")
}

// TestS2SResourceTags tests that all resources have proper tags
func TestS2SResourceTags(t *testing.T) {
	t.Parallel()

	namePrefix := fmt.Sprintf("test-tags-%s", strings.ToLower(random.UniqueId()))
	awsRegion := "us-east-1"
	expectedTags := map[string]string{
		"Environment":      "test",
		"Project":          "s2s-testing",
		"terraform-module": "tfm-aws-s2s",
	}

	terraformOptions := &terraform.Options{
		TerraformDir: "../",
		Vars: map[string]interface{}{
			"name_prefix": namePrefix,
			"aws_region":  awsRegion,
			"create_vpc":  true,
			"common_tags": expectedTags,
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Validate VPC tags
	vpcId := terraform.Output(t, terraformOptions, "vpc_id")
	vpc := aws.GetVpcById(t, vpcId, awsRegion)

	for key, expectedValue := range expectedTags {
		actualValue, exists := vpc.Tags[key]
		assert.True(t, exists, fmt.Sprintf("Tag '%s' should exist", key))
		assert.Equal(t, expectedValue, actualValue, fmt.Sprintf("Tag '%s' should have correct value", key))
	}
}

// TestS2SSecurityValidation tests security configurations
func TestS2SSecurityValidation(t *testing.T) {
	t.Parallel()

	namePrefix := fmt.Sprintf("test-sec-%s", strings.ToLower(random.UniqueId()))
	awsRegion := "us-east-1"

	terraformOptions := &terraform.Options{
		TerraformDir: "../",
		Vars: map[string]interface{}{
			"name_prefix":               namePrefix,
			"aws_region":                awsRegion,
			"create_vpc":                true,
			"create_vpn_security_group": true,
			"enable_vpc_flow_logs":      true,
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Validate security group configuration
	sgId := terraform.Output(t, terraformOptions, "vpn_security_group_id")
	if sgId != "" {
		sg := aws.GetSecurityGroupById(t, sgId, awsRegion)
		assert.NotEmpty(t, sg.IngressRules, "Security group should have ingress rules")

		// Validate that security group rules are not overly permissive
		for _, rule := range sg.IngressRules {
			if rule.Protocol == "tcp" || rule.Protocol == "udp" {
				assert.NotEqual(t, "0.0.0.0/0", rule.CidrBlocks[0],
					"Security group rules should not allow unrestricted access")
			}
		}
	}
}
