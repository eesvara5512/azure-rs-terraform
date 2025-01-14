# Bastion is part of the Vnet lifecycle hence part of the Vnet RG

resource "azurerm_public_ip" "sandbox_bastion_pip" {
  name                = "pip-bastion-sandbox-uks"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "sandbox" {
  name                = "bas-sandbox-uks"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.tfsubnet4.id
    public_ip_address_id = azurerm_public_ip.sandbox_bastion_pip.id
  }
}