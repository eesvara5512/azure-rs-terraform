###################
# Network Watcher
##################
# Network Watcher is linked to the Vnet lifecycle hence same RG

resource "azurerm_network_watcher" "nwwatcher" {
  name                = "nw-sandbox-uks"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_log_analytics_workspace" "sandbox_nw" {
  name                = "law-nw-sandbox-uks"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
}

resource "azurerm_network_watcher_flow_log" "sandbox_flowlogs" {
  network_watcher_name = azurerm_network_watcher.nwwatcher.name
  resource_group_name  = azurerm_resource_group.rg.name
  name                 = "sandbox-flowlogs"

  network_security_group_id = azurerm_network_security_group.NWnsg.id
  storage_account_id        = azurerm_storage_account.sandbox_DBprivdns.id
  enabled                   = true

  retention_policy {
    enabled = true
    days    = 7
  }

  traffic_analytics {
    enabled               = true
    workspace_id          = azurerm_log_analytics_workspace.sandbox_nw.workspace_id
    workspace_region      = azurerm_log_analytics_workspace.sandbox_nw.location
    workspace_resource_id = azurerm_log_analytics_workspace.sandbox_nw.id
    interval_in_minutes   = 10
  }
}