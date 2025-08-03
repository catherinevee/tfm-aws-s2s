# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2025-08-03

### Added
- Support for AWS Provider version 6.2.0
- VPC Flow Logs with CloudWatch integration
- Native Terraform tests
- Terratest integration
- GitHub Actions workflow for CI/CD
- Pre-commit hooks configuration
- Resource map in README.md
- Improved variable validations
- Security enhancements

### Changed
- Updated Terraform requirement to >= 1.13.0
- Split module into multiple files for better organization
- Enhanced documentation
- Improved resource naming convention
- Updated examples for latest provider version

### Fixed
- Various security improvements
- Better error messages in variable validations
- Resource dependencies and timing issues

## [1.0.0] - 2025-01-01

### Added
- Initial release of the module
- Basic VPN connectivity support
- Direct Connect support
- Transit Gateway integration
- Multi-AZ deployment capability
