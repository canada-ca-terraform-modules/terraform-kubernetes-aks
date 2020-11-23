# Virtual Networks

resource "azurerm_virtual_network" "vnet_aks" {
  name                = "${var.prefix}-vnet"
  location            = azurerm_resource_group.rg_aks.location
  resource_group_name = azurerm_resource_group.rg_aks.name
  address_space       = [var.vnet_cidr]
}

resource "azurerm_subnet" "subnet_aks" {
  name                 = "containers"
  resource_group_name  = azurerm_resource_group.rg_aks.name
  address_prefixes     = [var.subnet_cidr]
  virtual_network_name = azurerm_virtual_network.vnet_aks.name
  service_endpoints    = ["Microsoft.Sql"]
}
