# Bootstrap: creates the Azure Storage account that holds the Terraform state
# for the landing zone. Run it once, with local state, before the main code.

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id     = var.subscription_id
  storage_use_azuread = true
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_resource_group" "state" {
  name     = "rg-tfstate-${var.prefix}"
  location = var.location
  tags     = var.tags
}

resource "azurerm_storage_account" "state" {
  #checkov:skip=CKV_AZURE_33:Queue service is not used by the Terraform backend.
  #checkov:skip=CKV2_AZURE_1:Microsoft-managed keys are acceptable for state in this reference; use a customer-managed key in regulated environments.
  #checkov:skip=CKV2_AZURE_33:Private endpoint omitted so the state can be reached from CI runners and laptops; restrict with network rules instead.
  #checkov:skip=CKV_AZURE_59:Public network access is needed for hosted CI runners; access is limited by Entra ID authentication and RBAC.
  #checkov:skip=CKV_AZURE_35:Network rules depend on where CI runs; add an IP allow list for your runners.
  #checkov:skip=CKV_AZURE_206:LRS keeps the lab cheap; use GRS or ZRS in production.
  name                     = "sttfstate${var.prefix}${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.state.name
  location                 = azurerm_resource_group.state.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  min_tls_version                   = "TLS1_2"
  https_traffic_only_enabled        = true
  allow_nested_items_to_be_public   = false
  shared_access_key_enabled         = false
  infrastructure_encryption_enabled = true

  blob_properties {
    versioning_enabled = true

    delete_retention_policy {
      days = 30
    }

    container_delete_retention_policy {
      days = 30
    }
  }

  sas_policy {
    expiration_period = "01.00:00:00"
  }

  tags = var.tags
}

resource "azurerm_storage_container" "state" {
  #checkov:skip=CKV2_AZURE_21:Blob logging is configured through diagnostic settings on the account.
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.state.id
  container_access_type = "private"
}

data "azurerm_client_config" "current" {}

# Whoever runs Terraform needs data-plane access, because shared keys are disabled.
resource "azurerm_role_assignment" "state_contributor" {
  scope                = azurerm_storage_account.state.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}
