terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  # Remote state in Azure Storage. Create the storage account with the code
  # in bootstrap/, then uncomment and fill in with its backend_config output.
  # backend "azurerm" {
  #   resource_group_name  = "rg-tfstate-contoso"
  #   storage_account_name = "sttfstatecontosoxxxxxx"
  #   container_name       = "tfstate"
  #   key                  = "landing-zone.tfstate"
  #   use_azuread_auth     = true
  # }
}

provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
}
