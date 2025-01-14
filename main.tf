
############################
# Provider
#############################

# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }


  cloud {
    organization = "inmarsat"

    workspaces {
      name = "CIOP-AZURE-SANDBOX-INFRASTRUCTURE"
    }
  }

}


provider "azurerm" {
  skip_provider_registration = "true"
  features {}
}




module "sandbox" {
  source               = "./modules/sandbox"
  vnet-sandbox-uks     = "10.218.212.0/22"
  snet-dmz-sandbox-uks = "10.218.212.0/25"
  snet-web-sandbox-uks = "10.218.212.128/25"
  snet-app-sandbox-uks = "10.218.213.0/25"
  snet-db-sandbox-uks  = "10.218.213.128/25"
  # snet-bastion-sandbox-uks  = "10.218.215.64/26"
  bastion_subnet            = "10.218.215.64/26"
  snet-agw-sandbox-uks      = "10.218.215.192/26"
  snet-aviatrix-sandbox-uks = "10.218.215.176/28"
  location                  = "uksouth"
  environment               = "sandbox"
  azurerm_storage_account   = "stsandboxuks"
  resource_types            = ["KeyVaults", "StorageAccounts", "VirtualMachines"]
  password                  = "INMpass12345!"
}
