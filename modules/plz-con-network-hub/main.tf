#======================================#
# Network: Hub - Resource Group
#======================================#
# Create Resource Group.
resource "azurerm_resource_group" "plz_con_hub_rg" {
  name     = "${var.naming["prefix"]}-${var.naming["type"]}-con-hub-rg"
  location = var.location
  tags     = var.tags
}

#======================================#
# Network: Hub - VNet & Subnet
#======================================#

# Create: Virtual Network (Hub)
resource "azurerm_virtual_network" "plz_con_hub_vnet" {
  name                = "${var.naming["prefix"]}-${var.naming["type"]}-con-hub-vnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.plz_con_hub_rg.name
  address_space       = [var.vnet_space]
  tags                = var.tags
}

# Create: Virtual Network Subnet (Primary)
resource "azurerm_subnet" "plz_con_hub_sn1" {
  name                 = "${var.naming["prefix"]}-${var.naming["type"]}-con-hub-sn1"
  resource_group_name  = azurerm_virtual_network.plz_con_hub_vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.plz_con_hub_vnet.name
  address_prefixes     = [var.subnet_space]
  default_outbound_access_enabled = true # Disable for prevent system-assigned, outbound-only public IP.
}

#======================================#
# Network Security Group (NSG)
#======================================#

# NSG rules to be defined in separate files.
resource "azurerm_network_security_group" "plz_con_hub_sn1_nsg" {
  name                = "${var.naming["prefix"]}-${var.naming["type"]}-con-hub-sn1-nsg"
  location            = azurerm_virtual_network.plz_con_hub_vnet.location
  resource_group_name = azurerm_virtual_network.plz_con_hub_vnet.resource_group_name
  tags                = var.tags
}

# Associate NSG with subnet.
resource "azurerm_subnet_network_security_group_association" "plz_con_hub_sn1_nsg_assoc" {
  subnet_id                 = azurerm_subnet.plz_con_hub_sn1.id
  network_security_group_id = azurerm_network_security_group.plz_con_hub_sn1_nsg.id
}
