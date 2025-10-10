#======================================#
# Governance: Management Groups
#======================================#

# Create core top-level management group for the organization.
resource "azurerm_management_group" "mg_org_core" {
  display_name = var.core_management_group_display_name
  name         = "${var.core_management_group_id}"
}

# Create child management groups under core management group.
resource "azurerm_management_group" "mg_org_platform" {
  display_name = "Platform"
  name         = "${var.naming["prefix"]}-platform-mg"
  parent_management_group_id = azurerm_management_group.mg_org_core.id
  subscription_ids = [var.subscription_id] # List of platform subs.
}
resource "azurerm_management_group" "mg_org_workload" {
  display_name = "Workload"
  name         = "${var.naming["prefix"]}-workload-mg"
  parent_management_group_id = azurerm_management_group.mg_org_core.id
}
resource "azurerm_management_group" "mg_org_sandbox" {
  display_name = "Sandbox"
  name         = "${var.naming["prefix"]}-sandbox-mg"
  parent_management_group_id = azurerm_management_group.mg_org_core.id
}
resource "azurerm_management_group" "mg_org_decom" {
  display_name = "Decommissioned"
  name         = "${var.naming["prefix"]}-decom-mg"
  parent_management_group_id = azurerm_management_group.mg_org_core.id
}
