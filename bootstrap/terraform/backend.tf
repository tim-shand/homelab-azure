terraform {
  backend "azurerm" {
    resource_group_name  = "tjs-plz-platform-iac-rg"
    storage_account_name = "tjsplzplatform81661"
    container_name       = "tjs-plz-platform-iac-tfstate"
    key                  = "bootstrap.tfstate"
  }
}
