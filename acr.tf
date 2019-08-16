# Azure Container Registry

resource "azurerm_container_registry" "acr" {
  name                     = "${var.prefix}"
  resource_group_name      = "${azurerm_resource_group.rg_aks_development.name}"
  location                 = "${azurerm_resource_group.rg_aks_development.location}"
  sku                      = "Premium"
  admin_enabled            = false
  georeplication_locations = ["Canada East"]

  tags = {
    Environment = "Development"
  }
}
