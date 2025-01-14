
########################
# Create Private DNS Zone
########################
# We may modify the dns name below in future iterations
# Because the private dns zones are linked to storage for now, sam lifecycle as storage hence same resource

resource "azurerm_private_dns_zone" "dns-zone" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.rg3.name
}

#####################################
# Create Private DNS Zone Network Link
#####################################
resource "azurerm_private_dns_zone_virtual_network_link" "network_link" {
  name                  = "pl-st-sandbox-uks"
  resource_group_name   = azurerm_resource_group.rg3.name
  private_dns_zone_name = azurerm_private_dns_zone.dns-zone.name
  virtual_network_id = azurerm_virtual_network.TFNet.id
}

resource "azurerm_storage_account" "sandbox_DBprivdns" {
  name                     = var.azurerm_storage_account
  resource_group_name      = azurerm_resource_group.rg3.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = var.environment
  }
}

########################
# Create Private Endpoint
########################
resource "azurerm_private_endpoint" "endpoint" {
  name                = "pep-st-sandbox-uks"
  resource_group_name = azurerm_resource_group.rg3.name
  location            = var.location
  subnet_id           = azurerm_subnet.tfsubnet3.id
  private_service_connection {
    name                           = "psc-st-sandbox-uks"
    private_connection_resource_id = azurerm_storage_account.sandbox_DBprivdns.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }
}

#####################
# Create DNS A Record
#####################
resource "azurerm_private_dns_a_record" "dns_a" {
  name                = "clouduksouth"
  zone_name           = azurerm_private_dns_zone.dns-zone.name
  resource_group_name = azurerm_resource_group.rg3.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.endpoint.private_service_connection.0.private_ip_address]
}


######################
# key vault
######################

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "sandboxkey" {
  name                = "kv-sandbox-uk"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg3.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get",
      "Delete",
      "Backup", 
      "List", 
      "Purge", 
      "Recover", 
      "Restore", 
      "Set"
    ]

    storage_permissions = [
      "Get",
      "List",
      "Set",
      "SetSAS",
      "GetSAS",
      "DeleteSAS",
      "Update",
      "RegenerateKey"
    ]

    certificate_permissions = [
      "Backup",
      "Create",
      "Delete",
      "DeleteIssuers",
      "Get",
      "GetIssuers",
      "Import",
      "List",
      "ListIssuers",
      "ManageContacts",
      "ManageIssuers",
      "Purge",
      "Recover",
      "Restore",
      "SetIssuers",
      "Update"
    ]
  }
}


resource "azurerm_user_assigned_identity" "appag_umid" {
  name = "sandbox-appgw-umid"
  resource_group_name = azurerm_resource_group.rg4.name
  location            = var.location
}

resource "azurerm_key_vault_certificate" "sandboxcert" {
  name         = "imported-cert"
  key_vault_id = azurerm_key_vault.sandboxkey.id

  certificate {
    contents = filebase64("${path.module}/certS.pfx")
    password = var.password
  }
}

