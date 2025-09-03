variable resource_group_name {
  description = "Resource Group name"
  type        = string
  default     = "cdxp"
}

variable "subnet" {
  description = "subnet name"
  type        = string
}

variable "vnet_name" {
  description = "vnet name"
  type        = string
  default     = "cdxp-vnet"
}

variable "address_prefixes" {
  description = "address_prefixes"
  type        = list(string)
}

variable "service_endpoints" {
  description = "service_endpoints"
  type        = list(string)
}


variable "delegation_name" {
  description = "delegation name"
  type        = string
}

variable "actions" {
  description = "service_delegation action"
  type        = list(string)
}

variable "service_delegation_name" {
  description = "service delegation name"
  type        = string
}