terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.37.0"
    }
  }
}

provider "azurerm" {
  features {}
 client_id       = "26d9845b-1dff-4b40-9e28-144e9aaaebb7"
  client_secret   = "tPT8QI-SHe1ym1m76GptwiWWFdZ6lAzSiDAbCG"
  subscription_id = "289da116-5358-4835-8897-9e1db2cde3d2"
  tenant_id       = "150461e6-cf91-48a0-be99-6acb910fa44f"
}

