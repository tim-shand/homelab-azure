# SAFE TO COMMIT
# This file contains only non-sensitive configuration data (no credentials or secrets).
# All secrets are stored securely in Github Secrets or environment variables.

# Azure Settings.
location = "newzealandnorth" # Desired location for resources to be deployed in Azure.
management_group = "workload" # Desired ID for the top-level management group (under Tenant Root).

# Naming Settings (used for resource names).
naming = {
    prefix = "tjs" # Short name of organization ("abc").
    platform = "app" # Platform type: ("plz", "app")
    project = "wwwtshandcom" # Project name for related resources ("platform", "webapp01").
    service = "web" # Service name used in the project ("gov", "con", "sec").
    environment = "dev" # Environment for resources/project ("dev", "tst", "prd").
}

# Tags (assigned to all bootstrap resources).
tags = {
    Project = "Website-TShand-Com" # Name of the project the resources are for.
    Environment = "dev" # dev, tst, prd
    Owner = "CloudOps" # Team responsible for the resources.
    Creator = "IaC-Terraform" # Person or process that created the resources.
    ModifiedBy = "IaC-Terraform"
}

