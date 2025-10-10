# Azure Settings.
location = "newzealandnorth" # Desired location for resources to be deployed in Azure.

# Naming Settings (used for resource names).
naming = {
    prefix = "tjs" # Short name of organization ("abc").
    type = "mgt" # Short code for purpose/type of deployment ("mgt", "app").
    project = "platform" # Project name for related resources ("platform, application").
    service = "gov" # Service name used in the project ("iac", "gov", "sec").
    environment = "plz" # Environment for resources/project ("dev", "tst", "prd", "plz").
}

# Tags (assigned to all bootstrap resources).
tags = {
    Project = "Platform" # Name of the project the resources are for.
    Environment = "plz" # dev, tst, prd, plz
    Owner = "CloudOps" # Team responsible for the resources.
    Creator = "Terraform" # Person or process that created the resources.
}
