#create subnet1
resource "azurerm_subnet" "subnet"  {
  name                = var.subnet
  resource_group_name = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = var.address_prefixes
  service_endpoints   = var.service_endpoints

  delegation {
    name              = var.delegation_name

    service_delegation {
      actions         = var.actions

      name            = var.service_delegation_name
    }
  }

}
