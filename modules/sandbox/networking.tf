# locals {
#     zones    = ["1", "2", "3"] #Availability zones to spread the Application Gateway over. They are also only supported for v2 SKUs.
#   }

# locals {
#   zones = toset(["1","2","3"])
# }

############################
# Define a Virtual Network and Subnet
#############################
# Create virtual network
resource "azurerm_virtual_network" "TFNet" {
  name                = "vnet-sandbox-uks"
  address_space       = [var.vnet-sandbox-uks]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = {
    environment = var.environment
  }
}

#####################
# Create subnet
#####################

resource "azurerm_subnet" "tfsubnet" {
  name                 = "snet-dmz-sandbox-uks"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.TFNet.name
  address_prefixes     = [var.snet-dmz-sandbox-uks]
}
resource "azurerm_subnet" "tfsubnet1" {
  name                 = "snet-web-sandbox-uks"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.TFNet.name
  address_prefixes     = [var.snet-web-sandbox-uks]
}
resource "azurerm_subnet" "tfsubnet2" {
  name                 = "snet-app-sandbox-uks"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.TFNet.name
  address_prefixes     = [var.snet-app-sandbox-uks]
}
resource "azurerm_subnet" "tfsubnet3" {
  name                 = "snet-db-sandbox-uks"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.TFNet.name
  address_prefixes     = [var.snet-db-sandbox-uks]
}
resource "azurerm_subnet" "tfsubnet4" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.TFNet.name
  address_prefixes     = [var.bastion_subnet]
}
resource "azurerm_subnet" "tfsubnet5" {
  name                 = "snet-agw-sandbox-uks"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.TFNet.name
  address_prefixes     = [var.snet-agw-sandbox-uks]
}
resource "azurerm_subnet" "tfsubnet6" {
  name                 = "snet-aviatrix-sandbox-uks"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.TFNet.name
  address_prefixes     = [var.snet-aviatrix-sandbox-uks]
}

##################
# NIC
#################

resource "azurerm_network_interface" "dmzsrvnic1" {
  name                = "nic-dmzsrv1-Sandbox-uks"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg1.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.tfsubnet.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_network_interface" "dmzsrvnic2" {
  name                = "nic-dmzsrv2-Sandbox-uks"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg1.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.tfsubnet.id
    private_ip_address_allocation = "Dynamic"
  }
}



resource "azurerm_network_interface" "appsrvnic1" {
  name                = "nic-appsrv1-Sandbox-uks"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg2.name

  ip_configuration {
    name                          = "testconfiguration2"
    subnet_id                     = azurerm_subnet.tfsubnet2.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_network_interface" "appsrvnic2" {
  name                = "nic-appsrv2-Sandbox-uks"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg2.name

  ip_configuration {
    name                          = "testconfiguration2"
    subnet_id                     = azurerm_subnet.tfsubnet2.id
    private_ip_address_allocation = "Dynamic"
  }
}

#######################
# VMs and Disk
#######################t

resource "azurerm_windows_virtual_machine" "main" {
  name                  = "Z01S-DMZSRV1"
  location              = var.location
  resource_group_name   = azurerm_resource_group.rg1.name
  admin_username        = "spacegent"
  admin_password        = "INMpass12345!"
  network_interface_ids = [azurerm_network_interface.dmzsrvnic1.id]
    size                  = "Standard_DS1_v2"
  

 source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
  os_disk {
    name              = "osdisk-dmzsrv1-Sandbox-uks"
    caching           = "ReadWrite"
    # create_option     = "FromImage"
    storage_account_type = "Standard_LRS"
  }
  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.sandbox_DBprivdns.primary_blob_endpoint
 }

  tags = {
    environment = var.environment
  }
}

resource "azurerm_virtual_machine_extension" "vm-extensions" {
  # count = 1
  name                 = "Z01S-DMZSRV1"
  virtual_machine_id   = azurerm_windows_virtual_machine.main.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
    {
        "commandToExecute": "powershell -ExecutionPolicy Unrestricted Install-WindowsFeature -Name Web-Server -IncludeAllSubFeature -IncludeManagementTools"
    }
SETTINGS

}

resource "azurerm_windows_virtual_machine" "main1" {
  name                  = "Z01S-DMZSRV2"
  location              = var.location
  resource_group_name   = azurerm_resource_group.rg1.name
  admin_username        = "spacegent"
  admin_password        = "INMpass12345!"
  network_interface_ids = [azurerm_network_interface.dmzsrvnic2.id]
  size                  = "Standard_DS1_v2"
 

 

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
  os_disk {
    name              = "osdisk-dmzsrv2-Sandbox-uks"
    caching           = "ReadWrite"
    # create_option     = "FromImage"
    storage_account_type = "Standard_LRS"
  }
  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.sandbox_DBprivdns.primary_blob_endpoint
}
  
  tags = {
    environment = var.environment
  }
}

resource "azurerm_virtual_machine_extension" "vm-extensions1" {
  # count = 1
  name                 = "Z01S-DMZSRV2"
  virtual_machine_id   = azurerm_windows_virtual_machine.main1.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
    {
        "commandToExecute": "powershell -ExecutionPolicy Unrestricted Install-WindowsFeature -Name Web-Server -IncludeAllSubFeature -IncludeManagementTools"
    }
SETTINGS

}

resource "azurerm_windows_virtual_machine" "main2" {
  name                  = "Z01S-APPSRV1"
  location              = var.location
  resource_group_name   = azurerm_resource_group.rg2.name
  admin_username        = "spacegent"
  admin_password        = "INMpass12345!"
  network_interface_ids = [azurerm_network_interface.appsrvnic1.id]
  size                  = "Standard_DS1_v2"
  zone                  = ["1"]
  

 

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
  os_disk {
    name              = "osdisk-appsrv1-Sandbox-uks"
    caching           = "ReadWrite"
    # create_option     = "FromImage"
    storage_account_type = "Standard_LRS"
  }
  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.sandbox_DBprivdns.primary_blob_endpoint
}
  # os_profile {
  #   computer_name  = "hostname"
  #   admin_username = "spacegent"
  #   admin_password = "INMpass12345!"
  # }
  tags = {
    environment = var.environment
  }
}

resource "azurerm_virtual_machine_extension" "vm-extensions2" {
  # count = 1
  name                 = "Z01S-APPSRV1"
  virtual_machine_id   = azurerm_windows_virtual_machine.main2.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
    {
        "commandToExecute": "powershell -ExecutionPolicy Unrestricted Install-WindowsFeature -Name Web-Server -IncludeAllSubFeature -IncludeManagementTools"
    }
SETTINGS

}
resource "azurerm_windows_virtual_machine" "main3" {
  name                  = "Z01S-APPSRV2"
  location              = var.location
  resource_group_name   = azurerm_resource_group.rg2.name
  admin_username        = "spacegent"
  admin_password        = "INMpass12345!"
  network_interface_ids = [azurerm_network_interface.appsrvnic2.id]
  size                  = "Standard_DS1_v2"
  zone                  = ["2"]
  

 

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
  os_disk {
    name              = "osdisk-appsrv2-Sandbox-uks"
    caching           = "ReadWrite"
    # create_option     = "FromImage"
    storage_account_type = "Standard_LRS"
  }
  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.sandbox_DBprivdns.primary_blob_endpoint
 }
  # os_profile {
  #   computer_name  = "hostname"
  #   admin_username = "spacegent"
  #   admin_password = "INMpass12345!"
  # }
  tags = {
    environment = var.environment
  }
}
resource "azurerm_virtual_machine_extension" "vm-extensions3" {
  # count = 1
  name                 = "Z01S-APPSRV2"
  virtual_machine_id   = azurerm_windows_virtual_machine.main3.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
    {
        "commandToExecute": "powershell -ExecutionPolicy Unrestricted Install-WindowsFeature -Name Web-Server -IncludeAllSubFeature -IncludeManagementTools"
    }
SETTINGS

}
##################
# NSG
##################
# Nsgs to be applied Nics and focus on inbound rules

resource "azurerm_network_security_group" "dmzsrvnsg" {
  name                = "nsg-dmzsrvnic-Sandbox-uks"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg1.name

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = var.environment
  }
}
resource "azurerm_network_security_group" "appsrvnsg" {
  name                = "nsg-appsrvnic-Sandbox-uks"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg2.name

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = var.environment
  }
}
resource "azurerm_network_security_group" "NWnsg" {
  name                = "nsg-bastion-Sandbox-uks"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = var.environment
  }
}
resource "azurerm_network_interface_security_group_association" "dmzsrvnsg1" {
  network_interface_id      = azurerm_network_interface.dmzsrvnic1.id
  network_security_group_id = azurerm_network_security_group.dmzsrvnsg.id
}
resource "azurerm_network_interface_security_group_association" "dmzsrvnsg2" {
  network_interface_id      = azurerm_network_interface.dmzsrvnic2.id
  network_security_group_id = azurerm_network_security_group.dmzsrvnsg.id
}
resource "azurerm_network_interface_security_group_association" "appsrvnsg1" {
  network_interface_id      = azurerm_network_interface.appsrvnic1.id
  network_security_group_id = azurerm_network_security_group.appsrvnsg.id
}
resource "azurerm_network_interface_security_group_association" "appsrvnsg2" {
  network_interface_id      = azurerm_network_interface.appsrvnic2.id
  network_security_group_id = azurerm_network_security_group.appsrvnsg.id
}


###########################
# Route Table
###########################
# No route table for Bastion Subnets
# Route Tables linked to Subnets and thus same lifecycle as Vnet hence same RG

resource "azurerm_route_table" "rt_Sandbox_dmz" {
  name                          = "rt-dmzsnet-sandbox-uks"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.rg.name
  disable_bgp_route_propagation = false

  route {
    name           = "Sandbox_AllRoutesOut"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet"
  }

  tags = {
    environment = var.environment
  }
}
resource "azurerm_route_table" "rt_Sandbox_web" {
  name                          = "rt-websnet-sandbox-uks"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.rg.name
  disable_bgp_route_propagation = false

  route {
    name           = "Sandbox_AllRoutesOut"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet"
  }

  tags = {
    environment = var.environment
  }
}
resource "azurerm_route_table" "rt_Sandbox_app" {
  name                          = "rt-appsnet-sandbox-uks"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.rg.name
  disable_bgp_route_propagation = false

  route {
    name           = "Sandbox_AllRoutesOut"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet"
  }

  tags = {
    environment = var.environment
  }
}
resource "azurerm_route_table" "rt_Sandbox_db" {
  name                          = "rt-dbsnet-sandbox-uks"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.rg.name
  disable_bgp_route_propagation = false

  route {
    name           = "Sandbox_AllRoutesOut"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet"
  }

  tags = {
    environment = var.environment
  }
}
#########################################
# Associate subnets to the  route tables
##########################################

# example: now configured for multiple subnet association 

resource "azurerm_subnet_route_table_association" "tfsubent_association" {
  subnet_id      = azurerm_subnet.tfsubnet.id
  route_table_id = azurerm_route_table.rt_Sandbox_dmz.id
}
resource "azurerm_subnet_route_table_association" "tfsubent_association1" {
  subnet_id      = azurerm_subnet.tfsubnet1.id
  route_table_id = azurerm_route_table.rt_Sandbox_web.id
}
resource "azurerm_subnet_route_table_association" "tfsubent_association2" {
  subnet_id      = azurerm_subnet.tfsubnet2.id
  route_table_id = azurerm_route_table.rt_Sandbox_app.id
}
resource "azurerm_subnet_route_table_association" "tfsubent_association3" {
  subnet_id      = azurerm_subnet.tfsubnet3.id
  route_table_id = azurerm_route_table.rt_Sandbox_db.id
}
