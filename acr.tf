# Azure Container Registry

resource "azurerm_container_registry" "acr" {
  name                = "${var.short_prefix}acr"
  resource_group_name = azurerm_resource_group.rg_aks.name
  location            = azurerm_resource_group.rg_aks.location
  sku                 = "Premium"
  admin_enabled       = true
  # georeplication_locations = [var.georeplication_region]

  tags = {
    Environment = var.environment
  }
}
