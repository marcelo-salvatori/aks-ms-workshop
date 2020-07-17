resource "azurerm_virtual_network" "vnet" {
  name                  = var.vnet_name
  address_space         = ["10.0.0.0/8"]
  location              = "West Europe"
  resource_group_name   = var.node_resource_group

  subnet {
    name           = var.subnet_name
    address_prefix = "10.240.0.0/16"
  }
}