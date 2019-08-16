# Virtual Networks

resource "azurerm_virtual_network" "vnet_aks_development" {
  name                = "${var.prefix}-vnet-aks-development"
  location            = "${azurerm_resource_group.rg_network_development.location}"
  resource_group_name = "${azurerm_resource_group.rg_network_development.name}"
  address_space       = ["172.15.0.0/16"]
}

resource "azurerm_subnet" "subnet_aks_development" {
  name                 = "containers"
  resource_group_name  = "${azurerm_resource_group.rg_network_development.name}"
  address_prefix       = "172.15.4.0/22"
  virtual_network_name = "${azurerm_virtual_network.vnet_aks_development.name}"
}
