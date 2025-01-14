# locals {
#     zones    = ["1", "2", "3"] #Availability zones to spread the Application Gateway over. They are also only supported for v2 SKUs.
#   capacity = {
#     min = 1 #Minimum capacity for autoscaling. Accepted values are in the range 0 to 100.
#     max = 2 #Maximum capacity for autoscaling. Accepted values are in the range 2 to 125.
#   }
# }

resource "azurerm_public_ip" "sandboxip" {
  name                = "pip-agw-sandbox-uks"
  resource_group_name = azurerm_resource_group.rg4.name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "network" {
  name                = "agw-sandbox-uks"
  resource_group_name = azurerm_resource_group.rg4.name
  location            = var.location
  # zones               = local.zones

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  #  autoscale_configuration {
  #   min_capacity = local.capacity.min
  #   max_capacity = local.capacity.max
  # }

  gateway_ip_configuration {
    name      = "sandbox-gateway-ip-configuration"
    subnet_id = azurerm_subnet.tfsubnet5.id
  }

  frontend_port {
    name = var.frontend_port_name
    port = 80
  }

# What is the variable that is frontend_ip_configuration_name?

  frontend_ip_configuration {
    name                 = var.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.sandboxip.id
  }

  backend_address_pool {
    name = var.backend_address_pool_name
  }

  backend_http_settings {
    name                  = var.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  waf_configuration {
    # content {
      enabled          = "true"
      firewall_mode    = "Detection"
      rule_set_version = "3.0"
    # }
  }
  
  probe {
    name                = "probe_name_app1"
    host                = "127.0.0.1"
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3
    protocol            = "Http"
    port                = 80
    path                = "/"
    match { # Optional
      body              = "var.http_setting_name"
      status_code       = ["200-399"]
    }
  }   

  http_listener {
    name                           = var.listener_name
    frontend_ip_configuration_name = var.frontend_ip_configuration_name
    frontend_port_name             = var.frontend_port_name
    protocol                       = "Http"
  }

  ssl_certificate {
    name                = azurerm_key_vault_certificate.sandboxcert.name
    key_vault_secret_id = azurerm_key_vault_certificate.sandboxcert.secret_id
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.appag_umid.id]
  } 

  request_routing_rule {
    name                       = var.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = var.listener_name
    backend_address_pool_name  = var.backend_address_pool_name
    backend_http_settings_name = var.http_setting_name       
  }

}


# resource "azurerm_network_interface" "nic" {
#   count = 2
#   name                = "nic-${count.index+1}"
#   location            = var.location
#   resource_group_name = azurerm_resource_group.rg4.name

#   ip_configuration {
#     name                          = "nic-ipconfig-${count.index+1}"
#     subnet_id                     = azurerm_subnet.tfsubnet.id
#     private_ip_address_allocation = "Dynamic"
#   }

# }

resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "nic-agwapp1-sandbox-uks" {
  # count = 2
  
  network_interface_id = azurerm_network_interface.dmzsrvnic1.id
  ip_configuration_name   = "testconfiguration1"
  backend_address_pool_id = tolist(azurerm_application_gateway.network.backend_address_pool).0.id
}

resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "nic-agwapp2-sandbox-uks" {
  # count = 2
  # network_interface_id    = azurerm_network_interface.dmzsrvnic[count.index].id
  network_interface_id = azurerm_network_interface.dmzsrvnic2.id
  ip_configuration_name   = "testconfiguration1"
  backend_address_pool_id = tolist(azurerm_application_gateway.network.backend_address_pool).0.id
}


#######################
#defender
######################

resource "azurerm_security_center_subscription_pricing" "sp" {
  for_each = toset(var.resource_types)

  tier          = "Standard"
  resource_type = each.value
}

#####################
# WAF
#####################

# resource "azurerm_web_application_firewall_policy" "sandbox-waf" {
#   name                = "waf-policy-sandbox-uks"
#   resource_group_name = azurerm_resource_group.rg4.name
#   location            = var.location

#   custom_rules {
#     name      = "Rule1"
#     priority  = 1
#     rule_type = "MatchRule"

#     match_conditions {
#       match_variables {
#         variable_name = "RemoteAddr"
#       }

#       operator           = "IPMatch"
#       negation_condition = false
#       match_values       = ["192.168.1.0/24", "10.0.0.0/24"]
#     }

#     action = "Block"
#   }

#   custom_rules {
#     name      = "Rule2"
#     priority  = 2
#     rule_type = "MatchRule"

#     match_conditions {
#       match_variables {
#         variable_name = "RemoteAddr"
#       }

#       operator           = "IPMatch"
#       negation_condition = false
#       match_values       = ["192.168.1.0/24"]
#     }

#     match_conditions {
#       match_variables {
#         variable_name = "RequestHeaders"
#         selector      = "UserAgent"
#       }

#       operator           = "Contains"
#       negation_condition = false
#       match_values       = ["Windows"]
#     }

#     action = "Block"
#   }

#   policy_settings {
#     enabled                     = true
#     mode                        = "Prevention"
#     request_body_check          = true
#     file_upload_limit_in_mb     = 100
#     max_request_body_size_in_kb = 128
#   }
#   managed_rules {
#     managed_rule_set {
#       type    = "OWASP"
#       version = "3.1"
#     }
#   }
  
 
#  }




# resource "azurerm_web_application_firewall_policy_application_gateway_association" "example" {
#   association_type        = "ApplicationGateway"
#   waf_policy_id           = azurerm_web_application_firewall_policy.sandbox-waf.id
#   application_gateway_id  = azurerm_application_gateway.network.id
# }

