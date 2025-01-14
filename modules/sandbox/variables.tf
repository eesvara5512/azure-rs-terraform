 
variable "environment"{
  type        = string
  description = "environment identifier either prod,non-prod,sandbox,etc."
  default =  "sandbox"
}

variable "location"{
  type = string
  description = "regional location where resource will be deployed"
  default = "uksouth"
}

variable "password"{
  type = string
  description = "regional location where resource will be deployed"
  default = "password"
}

# variable "identity_id" {
#   type        = string
#   default     = null
#   description = "Specifies a user managed identity id to be assigned to the Application Gateway."
# }
# variable "ssl_certificates" {
#   type        = list(map(string))
#   default     = []
#   description = "List of objects that represent the configuration of each ssl certificate."
#   # ssl_certificates = [{ name = "", data = "", password = "", key_vault_secret_id = "" }]
# }

variable "resource_group_name_Vnet" {
  description = "A container that holds Vnet and subnet resources for the Azure Sandbox solution"
  default     = "rg-vnet-sandbox-uks"
}

variable "resource_group_name_VmDMZ" {
  description = "A container that holds Vnet and subnet resources for the Azure Sandbox solution"
  default     = "rg-dmzsrv-sandbox-uks"
}

variable "resource_group_name_VmAPP" {
  description = "A container that holds Vnet and subnet resources for the Azure Sandbox solution"
  default     = "rg-appsrv-sandbox-uks" 
}

variable "resource_group_name_VmDB" {
  description = "A container that holds Vnet and subnet resources for the Azure Sandbox solution"
  default     = "rg-dbsrv-sandbox-uks" 
}
variable "resource_group_name_Agw" {
  description = "A container that holds Vnet and subnet resources for the Azure Sandbox solution"
  default     = "rg-agw-sandbox-uks" 
}
variable "resource_group_name_Lb" {
  description = "A container that holds Vnet and subnet resources for the Azure Sandbox solution"
  default     = "rg-lb-sandbox-uks" 
}
variable "vnet-sandbox-uks" {
  type        = string
  description = "10.218.212.0/22"
}
variable "snet-dmz-sandbox-uks" {
  type        = string
  description = "10.218.212.0/25"
}

variable "snet-web-sandbox-uks" {
  type        = string
  description = "10.218.212.128/25"
}

variable "snet-app-sandbox-uks" {
  type        = string
  description = "10.218.213.0/25"
}

variable "snet-db-sandbox-uks" {
  type        = string
  description = "10.218.213.128/25"
}

# variable "snet-bastion-sandbox-uks" {
#   type        = string
#   description = "10.218.215.64/26"
# }

variable "bastion_subnet" {
  type        = string
  description = "10.218.215.64/26"
}

variable "snet-agw-sandbox-uks" {
  type        = string
  description = "10.218.215.192/26"
}

variable "snet-aviatrix-sandbox-uks" {
  type		  = string
  description = "10.218.215.176/28"
}

variable "azurerm_storage_account" {
  type        = string
  description = "stsandboxuks"
}

# Application gateway

# variable "sandbox_azgatewaysubnet" {
#   type        = string
#   description = "10.218.215.192/26"
# }

variable "backend_address_pool_name" {
    default = "AGW_BackendPool"
}

variable "frontend_port_name" {
    default = "AGW_FrontendPort"
}

variable "frontend_ip_configuration_name" {
    default = "AGW_feIPConfig"
}

variable "http_setting_name" {
    default = "AGW_HTTPsetting"
}

variable "listener_name" {
    default = "AGW_Listener"
}

variable "request_routing_rule_name" {
    default = "AGW_RoutingRule"
}

variable "redirect_configuration_name" {
    default = "AGW_RedirectConfig"
}

################
# defender
################
variable "resource_types" {
  description = "List of resource types to which Azure Defender should be enabled"
  type        = list(string)
  default     = []
}
