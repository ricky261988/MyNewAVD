terraform {
  backend "azurerm" {
    resource_group_name  = "PackerImage"
    storage_account_name = "avdtfstorage"
    container_name       = "acsdemo-tfstate"
    key                  = "prod.terraform.tfstate"
  }
}