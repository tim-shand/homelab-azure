﻿# SAFE TO COMMIT
# This file contains only non-sensitive configuration data (no credentials or secrets).
# All secrets are stored securely in Github Secrets or environment variables.

# Azure Settings.
location = "newzealandnorth" # Desired location for resources to be deployed in Azure.
core_management_group_id = "tjs-core-mg" # Desired ID for the top-level management group (under Tenant Root).
core_management_group_display_name = "TShand" # Desired display name for the top-level management group (under Tenant Root).

# Naming Settings (used for resource names).
naming = {
    prefix = "tjs" # Short name of organization ("abc").
    platform = "plz" # Platform type: ("plz", "app")
    project = "platform" # Project name for related resources ("platform", "webapp01").
    service = "iac" # Service name used in the project ("gov", "con", "sec").
    environment = "prd" # Environment for resources/project ("dev", "tst", "prd").
}

# Tags (assigned to all bootstrap resources).
tags = {
    Project = "Platform" # Name of the project the resources are for.
    Environment = "prd" # dev, tst, prd
    Owner = "CloudOps" # Team responsible for the resources.
    Creator = "Bootstrapper" # Person or process that created the resources.
    Modified = "20251010.211532" # Last modified timestamp.
    ModifiedBy = "IaC-Terraform"
}

# Github Settings.
github_config = {
    org = "tim-shand" # Github organization where repository is located.
    repo = "homelab-azure" # Github repository to use for adding secrets and variables.
    branch = "main" # Using main branch of repository.
}
