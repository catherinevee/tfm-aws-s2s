package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestS2SModule(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/basic-vpn",
		Vars: map[string]interface{}{
			"name_prefix":          "test-s2s",
			"vpc_cidr_block":       "10.0.0.0/16",
			"private_subnet_cidrs": []string{"10.0.1.0/24", "10.0.2.0/24"},
			"public_subnet_cidrs":  []string{"10.0.101.0/24", "10.0.102.0/24"},
			"enable_vpc_flow_logs": true,
		},
	}
	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	vpcID := terraform.Output(t, terraformOptions, "vpc_id")
	assert.NotEmpty(t, vpcID, "VPC ID should not be empty")

	privateSubnetIDs := terraform.OutputList(t, terraformOptions, "private_subnet_ids")
	assert.Equal(t, 2, len(privateSubnetIDs), "Should have created 2 private subnets")
}
