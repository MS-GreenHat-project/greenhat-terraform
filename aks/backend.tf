terraform {
  backend "azurerm" {
    resource_group_name  = "Green-Hat"
    storage_account_name = "greenhat111"
    container_name       = "tfstate"
    key                  = "aks/terraform.tfstate"
  }
}
