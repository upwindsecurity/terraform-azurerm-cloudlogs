# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

Terraform module repository for Upwind Security Azure integration — automates Azure Monitor diagnostic settings and infrastructure to enable centralized cloud log collection via Event Hub.

## Commands

```bash
# Format code
make fmt

# Run basic tests (validate + format + lint)
make test

# Run all tests including security scan
make test-all

# Test a specific module
make test-module MODULE=eventhub
make test-module MODULE=auto-discovery

# Individual test types
make test-validate    # terraform validate on all modules/examples
make test-format      # terraform fmt --check
make test-lint        # TFLint
make test-security    # Trivy security scan

# Generate/update documentation
make docs

# Initialize all modules and examples
make init

# Run pre-commit hooks
make pre-commit

# Install required tools (terraform-docs, pre-commit, tflint, trivy)
make install-tools
```

## Architecture

Two core modules under `modules/`:

### `modules/eventhub`
Main integration module. Creates:
- Azure AD app registration + service principal (or uses existing ones)
- Event Hub namespace + Event Hub
- Azure Key Vault for storing credentials
- Diagnostic settings to stream Activity logs and Entra ID logs to Event Hub

Supports streaming at subscription, management group, or tenant-wide scope. Optionally delegates to the `auto-discovery` sub-module for policy-based automation.

### `modules/auto-discovery`
Called by the `eventhub` module when `enable_auto_discovery = true`. Uses Azure Policy to automatically apply diagnostic settings to new subscriptions within a management group.

### Examples
Seven example configurations in `examples/` covering: basic subscription setup, existing Event Hub integration, tenant-wide monitoring, management group scope, auto-discovery, separate diagnostic settings, and infrastructure-only deployment.

## Conventions

- Terraform >= 1.9, azurerm >= 4.42.0, azuread >= 3.4
- Naming convention: snake_case (enforced by TFLint)
- All variables and outputs must be documented (TFLint enforces this)
- Module structure must follow standard Terraform layout (TFLint enforces this)
- PR titles must follow semantic commit format: `type(scope): description` with lowercase subject
- Commit types: fix, feat, docs, style, refactor, perf, test, build, ci, chore, revert

## CI/CD

- `.github/workflows/ci.yml` — main pipeline: format check, validate, lint, security scan, docs validation
- `.github/workflows/release.yml` — automated semantic versioning and Terraform Registry publishing
- Example testing is triggered by PR label `test-examples` or commit message `[test-examples]`
