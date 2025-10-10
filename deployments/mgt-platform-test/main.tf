# EXAMPLE: Code for deploying Azure Platform Landing Zone.

# Create Resource Group.
resource "azurerm_resource_group" "plz_rg_test" {
  name     = "${var.naming["prefix"]}-${var.naming["type"]}-${var.naming["project"]}-${var.naming["service"]}-${var.naming["environment"]}-rg"
  location = var.location
  tags     = var.tags
}
