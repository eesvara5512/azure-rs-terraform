
# locals {
#     zones    = ["1", "2", "3"] #Availability zones to spread the Application Gateway over. They are also only supported for v2 SKUs.
#  }

#Create Private Network Interfaces
resource "azurerm_network_interface" "corpnic" {
  name                = "nic-lb-sanndbox-uks-${count.index + 1}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg5.name
  count               = 2

  ip_configuration {
    name                          = "ipconfig-${count.index + 1}"
    subnet_id                     = azurerm_subnet.tfsubnet.id
    private_ip_address_allocation = "Dynamic"

  }
}

#Create Load Balancer
resource "azurerm_lb" "business-tier-lb" {
  name                = "lb-dmzapp-sandbox-uks"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg5.name

  frontend_ip_configuration {
    name                          = "standard-lb-frontend-ip"
    subnet_id                     = azurerm_subnet.tfsubnet.id
    # zones                         = local.zones
   
  }
}

#Create Loadbalancing Rules
resource "azurerm_lb_rule" "production-inbound-rules" {
  loadbalancer_id                = azurerm_lb.business-tier-lb.id
  name                           = "ssh-inbound-rule"
  protocol                       = "Tcp"
  frontend_port                  = 22
  backend_port                   = 22
  frontend_ip_configuration_name = "standard-lb-frontend-ip"
 
 

}

#Create Probe
resource "azurerm_lb_probe" "ssh-inbound-probe" {
  loadbalancer_id     = azurerm_lb.business-tier-lb.id
  name                = "ssh-inbound-probe"
  port                = 22
}

#Create Backend Address Pool
resource "azurerm_lb_backend_address_pool" "business-backend-pool" {
  loadbalancer_id = azurerm_lb.business-tier-lb.id
  name            = "business-backend-pool"
}





# # Create Network Security Group and rule
# resource "azurerm_network_security_group" "corporate-production-nsg" {
#   name                = "corporate-production-nsg"
#   location            = azurerm_resource_group.rg5.location
#   resource_group_name = azurerm_resource_group.rg5.name


#   #Add rule for Inbound Access
#   security_rule {
#     name                       = "SSH"
#     priority                   = 1001
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = var.ssh_access_port # Referenced SSH Port 22 from vars.tf file.
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   }
# }


# #Connect NSG to Subnet
# resource "azurerm_subnet_network_security_group_association" "corporate-production-nsg-assoc" {
#   subnet_id                 = azurerm_subnet.business-tier-subnet.id
#   network_security_group_id = azurerm_network_security_group.corporate-production-nsg.id
# }



# #Availability Set - Fault Domains [Rack Resilience]
# resource "azurerm_availability_set" "vmavset" {
#   name                         = "vmavset"
#   location                     = azurerm_resource_group.rg5.location
#   resource_group_name          = azurerm_resource_group.rg5.name
#   platform_fault_domain_count  = 2
#   platform_update_domain_count = 2
#   managed                      = true
#   tags = {
#     environment = "Production"
#   }
# }


#Create Linux Virtual Machines Workloads
#resource "azurerm_linux_virtual_machine" "corporate-business-linux-vm" {

#  name                  = "${var.corp}linuxvm${count.index}"
#  location              = azurerm_resource_group.rg5.location
#  resource_group_name   = azurerm_resource_group.rg5.name
#  availability_set_id   = azurerm_availability_set.vmavset.id
#  network_interface_ids = ["${element(azurerm_network_interface.corpnic.*.id, count.index)}"]
#  size                  =  "Standard_B1s"  # "Standard_D2ads_v5" # "Standard_DC1ds_v3" "Standard_D2s_v3"
#  count                 = 2


  #Create Operating System Disk
#  os_disk {
#    name                 = "${var.corp}disk${count.index}"
#    caching              = "ReadWrite"
#    storage_account_type = "Standard_LRS" #Consider Storage Type
#  }


  #Reference Source Image from Publisher
#  source_image_reference {
#    publisher = "Canonical"                    #az vm image list -p "Canonical" --output table
#    offer     = "0001-com-ubuntu-server-focal" # az vm image list -p "Canonical" --output table
#    sku       = "20_04-lts-gen2"               #az vm image list -s "20.04-LTS" --output table
#    version   = "latest"
#  }


  #Create Computer Name and Specify Administrative User Credentials
#  computer_name                   = "corporate-linux-vm${count.index}"
#  admin_username                  = "linuxsvruser${count.index}"
#  disable_password_authentication = true



  #Create SSH Key for Secured Authentication - on Windows Management Server [Putty + PrivateKey]
#  admin_ssh_key {
#    username   = "linuxsvruser${count.index}"
#    public_key = tls_private_key.linuxvmsshkey.public_key_openssh
#  }

  #Deploy Custom Data on Hosts
#  custom_data = data.template_cloudinit_config.webserverconfig.rendered

#}