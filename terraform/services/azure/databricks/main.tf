provider "azurerm" {
  features {}
  subscription_id = "d2a326c1-2b9a-439d-98b0-1e038c7880d6"
}

#user env
locals {
  prefix = "lc-crm"
  rg      = "lc-crm"
  location = "eastasia"
}

#get vnet id
data "azurerm_virtual_network" "vnet" {
  name                = "${local.prefix}-vnet"
  resource_group_name = local.rg
}

#create public / host subnet (using)
module "public_subnet" {
  source = "../../modules/svc-subnet"
  subnet = "${local.prefix}-databricks-public-subnet"
  resource_group_name = local.rg
  vnet_name = "${local.prefix}-vnet"
  address_prefixes = ["16.0.8.0/22"]

  service_endpoints = ["Microsoft.Storage"]
  delegation_name = "${local.prefix}-databricks-public"
  actions = [
    "Microsoft.Network/virtualNetworks/subnets/join/action",
    "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
    "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action",
  ]
  service_delegation_name = "Microsoft.Databricks/workspaces"
}

#create private / container subnet (using)
module "private_subnet" {
  source = "../../modules/svc-subnet"
  subnet = "${local.prefix}-databricks-private-subnet"
  resource_group_name = local.rg
  vnet_name = "${local.prefix}-vnet"
  address_prefixes = ["16.0.4.0/22"]

  service_endpoints = ["Microsoft.Storage"]
  delegation_name = "${local.prefix}-databricks-private"
  actions = [
    "Microsoft.Network/virtualNetworks/subnets/join/action",
    "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
    "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action",
  ]
  service_delegation_name = "Microsoft.Databricks/workspaces"
}

#create subnet1 subnet
module "endpoint"  {
  source                = "../../modules/subnet"
  subnet                = "endpoint"
  resource_group_name   = local.rg
  vnet_name             = "${local.prefix}-vnet"
  address_prefixes      = ["16.0.12.0/22"]
}


//create nsg
resource "azurerm_network_security_group" "nsg" {
  name                = "${local.prefix}-databricks-nsg"
  location            = local.location
  resource_group_name = local.rg
}

resource "azurerm_subnet_network_security_group_association" "private" {
  subnet_id                 = module.private_subnet.subnet_id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_subnet_network_security_group_association" "public" {
  subnet_id                 = module.public_subnet.subnet_id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

//create workspace
resource "azurerm_databricks_workspace" "databricks" {
  name                        = "${local.prefix}-databricks"
  resource_group_name         = local.rg
  location                    = local.location
  sku                         = "premium"
  managed_resource_group_name = "${local.prefix}-managed-databricks"

  public_network_access_enabled         = true
  network_security_group_rules_required = "AllRules"

  custom_parameters {
    no_public_ip        = true
    public_subnet_name  = module.public_subnet.subnet_name
    private_subnet_name = module.private_subnet.subnet_name
    virtual_network_id  = data.azurerm_virtual_network.vnet.id

    public_subnet_network_security_group_association_id  = azurerm_subnet_network_security_group_association.public.id
    private_subnet_network_security_group_association_id = azurerm_subnet_network_security_group_association.private.id
  }

  tags = {
    project = "LC CRM"
    ProjectCode = "P00105"
    RootProjectCode = "BL00016"
  }
}


