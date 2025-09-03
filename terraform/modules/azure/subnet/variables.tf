variable resource_group_name {
  description = "Resource Group name"
  type        = string
}


variable "subnet" {
  description = "Subnet Name"
  type        = string
}

variable "vnet_name" {
  description = "vnet name"
  type        = string
}

variable "address_prefixes" {
  description = "address_prefixes"
  type        = list(string)
}
