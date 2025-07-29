# =============================================================================
# Makefile for AWS Site-to-Site Connectivity Module
# =============================================================================

# Variables
TF_VERSION := $(shell terraform version -json | jq -r '.terraform_version')
AWS_REGION ?= us-east-1
ENVIRONMENT ?= development
WORKSPACE ?= default

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[0;33m
BLUE := \033[0;34m
NC := \033[0m # No Color

# Default target
.DEFAULT_GOAL := help

# Help target
.PHONY: help
help: ## Show this help message
	@echo "$(BLUE)AWS Site-to-Site Connectivity Module$(NC)"
	@echo "$(BLUE)=====================================$(NC)"
	@echo ""
	@echo "$(YELLOW)Available commands:$(NC)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "$(YELLOW)Environment variables:$(NC)"
	@echo "  AWS_REGION    - AWS region (default: us-east-1)"
	@echo "  ENVIRONMENT   - Environment name (default: development)"
	@echo "  WORKSPACE     - Terraform workspace (default: default)"

# =============================================================================
# Setup and Validation
# =============================================================================

.PHONY: init
init: ## Initialize Terraform
	@echo "$(BLUE)Initializing Terraform...$(NC)"
	terraform init -upgrade
	@echo "$(GREEN)✓ Terraform initialized$(NC)"

.PHONY: validate
validate: ## Validate Terraform configuration
	@echo "$(BLUE)Validating Terraform configuration...$(NC)"
	terraform validate
	@echo "$(GREEN)✓ Configuration is valid$(NC)"

.PHONY: fmt
fmt: ## Format Terraform code
	@echo "$(BLUE)Formatting Terraform code...$(NC)"
	terraform fmt -recursive
	@echo "$(GREEN)✓ Code formatted$(NC)"

.PHONY: check
check: fmt validate ## Check code quality (format + validate)
	@echo "$(GREEN)✓ All checks passed$(NC)"

# =============================================================================
# Workspace Management
# =============================================================================

.PHONY: workspace
workspace: ## Create and select Terraform workspace
	@echo "$(BLUE)Managing Terraform workspace...$(NC)"
	terraform workspace new $(WORKSPACE) 2>/dev/null || terraform workspace select $(WORKSPACE)
	@echo "$(GREEN)✓ Workspace '$(WORKSPACE)' selected$(NC)"

.PHONY: workspace-list
workspace-list: ## List all Terraform workspaces
	@echo "$(BLUE)Available workspaces:$(NC)"
	terraform workspace list

# =============================================================================
# Planning and Deployment
# =============================================================================

.PHONY: plan
plan: init workspace ## Create Terraform plan
	@echo "$(BLUE)Creating Terraform plan...$(NC)"
	terraform plan -var="aws_region=$(AWS_REGION)" -var="environment=$(ENVIRONMENT)" -out=tfplan
	@echo "$(GREEN)✓ Plan created: tfplan$(NC)"

.PHONY: apply
apply: plan ## Apply Terraform changes
	@echo "$(YELLOW)Applying Terraform changes...$(NC)"
	@read -p "Do you want to apply these changes? (y/N): " confirm && [ "$$confirm" = "y" ] || exit 1
	terraform apply tfplan
	@echo "$(GREEN)✓ Changes applied successfully$(NC)"

.PHONY: apply-auto
apply-auto: plan ## Apply Terraform changes without confirmation
	@echo "$(BLUE)Applying Terraform changes...$(NC)"
	terraform apply tfplan
	@echo "$(GREEN)✓ Changes applied successfully$(NC)"

.PHONY: destroy
destroy: init workspace ## Destroy Terraform resources
	@echo "$(RED)Destroying Terraform resources...$(NC)"
	@read -p "Are you sure you want to destroy all resources? (y/N): " confirm && [ "$$confirm" = "y" ] || exit 1
	terraform destroy -var="aws_region=$(AWS_REGION)" -var="environment=$(ENVIRONMENT)"
	@echo "$(GREEN)✓ Resources destroyed$(NC)"

# =============================================================================
# State Management
# =============================================================================

.PHONY: state-list
state-list: ## List all resources in Terraform state
	@echo "$(BLUE)Resources in Terraform state:$(NC)"
	terraform state list

.PHONY: state-show
state-show: ## Show Terraform state (usage: make state-show RESOURCE=aws_vpc.main)
	@if [ -z "$(RESOURCE)" ]; then \
		echo "$(RED)Error: RESOURCE variable is required$(NC)"; \
		echo "Usage: make state-show RESOURCE=aws_vpc.main"; \
		exit 1; \
	fi
	@echo "$(BLUE)Showing state for $(RESOURCE):$(NC)"
	terraform state show $(RESOURCE)

.PHONY: state-rm
state-rm: ## Remove resource from Terraform state (usage: make state-rm RESOURCE=aws_vpc.main)
	@if [ -z "$(RESOURCE)" ]; then \
		echo "$(RED)Error: RESOURCE variable is required$(NC)"; \
		echo "Usage: make state-rm RESOURCE=aws_vpc.main"; \
		exit 1; \
	fi
	@echo "$(YELLOW)Removing $(RESOURCE) from Terraform state...$(NC)"
	@read -p "Are you sure? (y/N): " confirm && [ "$$confirm" = "y" ] || exit 1
	terraform state rm $(RESOURCE)
	@echo "$(GREEN)✓ Resource removed from state$(NC)"

# =============================================================================
# Output and Information
# =============================================================================

.PHONY: output
output: ## Show Terraform outputs
	@echo "$(BLUE)Terraform outputs:$(NC)"
	terraform output

.PHONY: graph
graph: ## Generate Terraform dependency graph
	@echo "$(BLUE)Generating Terraform dependency graph...$(NC)"
	terraform graph | dot -Tsvg > terraform-graph.svg
	@echo "$(GREEN)✓ Graph saved as terraform-graph.svg$(NC)"

.PHONY: version
version: ## Show Terraform and provider versions
	@echo "$(BLUE)Terraform version:$(NC)"
	terraform version
	@echo ""
	@echo "$(BLUE)Provider versions:$(NC)"
	terraform providers

# =============================================================================
# Security and Compliance
# =============================================================================

.PHONY: security-scan
security-scan: ## Run security scan with tfsec
	@echo "$(BLUE)Running security scan...$(NC)"
	@if command -v tfsec >/dev/null 2>&1; then \
		tfsec .; \
	else \
		echo "$(YELLOW)tfsec not installed. Install with: brew install tfsec$(NC)"; \
	fi

.PHONY: compliance-check
compliance-check: ## Run compliance check with checkov
	@echo "$(BLUE)Running compliance check...$(NC)"
	@if command -v checkov >/dev/null 2>&1; then \
		checkov -d .; \
	else \
		echo "$(YELLOW)checkov not installed. Install with: pip install checkov$(NC)"; \
	fi

# =============================================================================
# Testing
# =============================================================================

.PHONY: test
test: ## Run Terratest (if available)
	@echo "$(BLUE)Running tests...$(NC)"
	@if [ -d "test" ]; then \
		cd test && go test -v -timeout 30m; \
	else \
		echo "$(YELLOW)No test directory found$(NC)"; \
	fi

# =============================================================================
# Cleanup
# =============================================================================

.PHONY: clean
clean: ## Clean up temporary files
	@echo "$(BLUE)Cleaning up temporary files...$(NC)"
	rm -f tfplan
	rm -f terraform-graph.svg
	rm -f .terraform.lock.hcl
	@echo "$(GREEN)✓ Cleanup completed$(NC)"

.PHONY: clean-all
clean-all: clean ## Clean up all files including .terraform directory
	@echo "$(BLUE)Cleaning up all files...$(NC)"
	rm -rf .terraform
	rm -rf .terraform.lock.hcl
	@echo "$(GREEN)✓ Complete cleanup completed$(NC)"

# =============================================================================
# Documentation
# =============================================================================

.PHONY: docs
docs: ## Generate documentation
	@echo "$(BLUE)Generating documentation...$(NC)"
	@if command -v terraform-docs >/dev/null 2>&1; then \
		terraform-docs markdown table . > README.md.tmp && \
		mv README.md.tmp README.md; \
		echo "$(GREEN)✓ Documentation generated$(NC)"; \
	else \
		echo "$(YELLOW)terraform-docs not installed. Install with: brew install terraform-docs$(NC)"; \
	fi

# =============================================================================
# Examples
# =============================================================================

.PHONY: examples
examples: ## List available examples
	@echo "$(BLUE)Available examples:$(NC)"
	@for example in examples/*/; do \
		if [ -d "$$example" ]; then \
			echo "  - $$(basename $$example)"; \
		fi; \
	done

.PHONY: example-plan
example-plan: ## Plan a specific example (usage: make example-plan EXAMPLE=basic-vpn)
	@if [ -z "$(EXAMPLE)" ]; then \
		echo "$(RED)Error: EXAMPLE variable is required$(NC)"; \
		echo "Usage: make example-plan EXAMPLE=basic-vpn"; \
		exit 1; \
	fi
	@echo "$(BLUE)Planning example: $(EXAMPLE)$(NC)"
	@cd examples/$(EXAMPLE) && terraform init && terraform plan

.PHONY: example-apply
example-apply: ## Apply a specific example (usage: make example-apply EXAMPLE=basic-vpn)
	@if [ -z "$(EXAMPLE)" ]; then \
		echo "$(RED)Error: EXAMPLE variable is required$(NC)"; \
		echo "Usage: make example-apply EXAMPLE=basic-vpn"; \
		exit 1; \
	fi
	@echo "$(BLUE)Applying example: $(EXAMPLE)$(NC)"
	@cd examples/$(EXAMPLE) && terraform init && terraform apply -auto-approve

.PHONY: example-destroy
example-destroy: ## Destroy a specific example (usage: make example-destroy EXAMPLE=basic-vpn)
	@if [ -z "$(EXAMPLE)" ]; then \
		echo "$(RED)Error: EXAMPLE variable is required$(NC)"; \
		echo "Usage: make example-destroy EXAMPLE=basic-vpn"; \
		exit 1; \
	fi
	@echo "$(RED)Destroying example: $(EXAMPLE)$(NC)"
	@cd examples/$(EXAMPLE) && terraform destroy -auto-approve

# =============================================================================
# Development
# =============================================================================

.PHONY: dev-setup
dev-setup: ## Setup development environment
	@echo "$(BLUE)Setting up development environment...$(NC)"
	@if command -v pre-commit >/dev/null 2>&1; then \
		pre-commit install; \
		echo "$(GREEN)✓ Pre-commit hooks installed$(NC)"; \
	else \
		echo "$(YELLOW)pre-commit not installed. Install with: pip install pre-commit$(NC)"; \
	fi
	@echo "$(GREEN)✓ Development environment ready$(NC)"

.PHONY: pre-commit
pre-commit: ## Run pre-commit hooks
	@echo "$(BLUE)Running pre-commit hooks...$(NC)"
	@if command -v pre-commit >/dev/null 2>&1; then \
		pre-commit run --all-files; \
	else \
		echo "$(YELLOW)pre-commit not installed$(NC)"; \
	fi 