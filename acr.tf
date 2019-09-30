# Azure Container Registry

resource "azurerm_container_registry" "acr" {
  name                     = "${var.prefix}acr"
  resource_group_name      = "${azurerm_resource_group.rg_aks.name}"
  location                 = "${azurerm_resource_group.rg_aks.location}"
  sku                      = "Premium"
  admin_enabled            = false
  georeplication_locations = ["${var.georeplication_region}"]

  tags = {
    Environment = "${var.environment}"
  }
}
