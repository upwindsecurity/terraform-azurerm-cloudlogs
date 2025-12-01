# Terraform Modules for Microsoft Azure Cloud Logs

[![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Microsoft Azure](https://img.shields.io/badge/Microsoft%20Azure-%230072C6.svg?style=for-the-badge&logo=microsoftazure&logoColor=white)](https://azure.microsoft.com/)
[![GitHub Actions](https://img.shields.io/badge/github%20actions-%232671E5.svg?style=for-the-badge&logo=githubactions&logoColor=white)](https://github.com/features/actions)
[![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg?style=for-the-badge)](https://opensource.org/licenses/Apache-2.0)

## Overview

This repository contains the following Terraform modules for Microsoft Azure cloud logs.

These modules automate the creation of
[Azure Monitor diagnostic settings](https://learn.microsoft.com/en-us/azure/azure-monitor/platform/diagnostic-settings)
and the necessary infrastructure to enable Upwind to access Azure Monitor Logs for centralized observability and
threat detection.

Diagnostic settings allow you to collect resource logs and send platform metrics and activity logs to different destinations.

## Modules

- [modules/eventhub/](https://github.com/upwindsecurity/terraform-azurerm-cloudlogs/tree/main/modules/eventhub/) -
  Azure Monitor Logs via Event Hub
- [modules/auto-discovery](https://github.com/upwindsecurity/terraform-azurerm-cloudlogs/tree/main/modules/auto-discovery/)
  \- Auto creating diagnostic settings on selected scope (inner module)

## Examples

Complete usage examples are available in the
[examples](https://github.com/upwindsecurity/terraform-azurerm-cloudlogs/tree/main/examples/) directory:

- [eventhub-basic](https://github.com/upwindsecurity/terraform-azurerm-cloudlogs/tree/main/examples/eventhub-basic/) -
  Simple subscription-based monitoring
- [eventhub-management-groups](https://github.com/upwindsecurity/terraform-azurerm-cloudlogs/tree/main/examples/eventhub-management-groups/)
  \- Enterprise organizational monitoring
- [eventhub-existing](https://github.com/upwindsecurity/terraform-azurerm-cloudlogs/tree/main/examples/eventhub-existing/)
  \- Integration with existing Event Hub
- [eventhub-tenant-wide](https://github.com/upwindsecurity/terraform-azurerm-cloudlogs/tree/main/examples/eventhub-tenant-wide/)
  \- Tenant-wide monitoring with exclusions
- [auto-discovery](https://github.com/upwindsecurity/terraform-azurerm-cloudlogs/tree/main/examples/auto-discovery-basic-usage/)
  \- Auto-Discovery Basic usage example

## Contributing

We welcome contributions! Please see our
[CONTRIBUTING.md](https://github.com/upwindsecurity/terraform-azurerm-cloudlogs/blob/main/CONTRIBUTING.md) guide for
details on:

- Development setup and workflows
- Testing procedures
- Code standards and best practices
- How to add new submodules

For bug reports and feature requests, please use
[GitHub Issues](https://github.com/upwindsecurity/terraform-azurerm-cloudlogs/issues).

## Versioning

We use [Semantic Versioning](http://semver.org/) for releases. For the versions
available, see the [tags on this repository](https://github.com/upwindsecurity/terraform-azurerm-cloudlogs/tags).

## License

This project is licensed under the Apache License 2.0. See the
[LICENSE](https://github.com/upwindsecurity/terraform-azurerm-cloudlogs/blob/main/LICENSE) file for details.

## Support

- [Documentation](https://docs.upwind.io)
- [Issues](https://github.com/upwindsecurity/terraform-azurerm-cloudlogs/issues)
- [Contributing Guide](https://github.com/upwindsecurity/terraform-azurerm-cloudlogs/blob/main/CONTRIBUTING.md)
