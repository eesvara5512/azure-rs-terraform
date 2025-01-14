resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name_Vnet
  location = var.location
  
  tags = {
    environment = var.environment
  }
}

resource "azurerm_resource_group" "rg1" {
  name     = var.resource_group_name_VmDMZ
  location = var.location
  
  tags = {
    environment = var.environment
  }
}

resource "azurerm_resource_group" "rg2" {
  name     = var.resource_group_name_VmAPP
  location = var.location
  
  tags = {
    environment = var.environment
  }
}

resource "azurerm_resource_group" "rg3" {
  name     = var.resource_group_name_VmDB
  location = var.location
  
  tags = {
    environment = var.environment
  }
}

resource "azurerm_resource_group" "rg4" {
  name     = var.resource_group_name_Agw
  location = var.location
  
  tags = {
    environment = var.environment
  }
}

resource "azurerm_resource_group" "rg5" {
  name     = var.resource_group_name_Lb
  location = var.location
  
  tags = {
    environment = var.environment
  }
}