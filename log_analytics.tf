# Log Analytics

resource "azurerm_log_analytics_workspace" "workspace_aks_development" {
  name                = "${var.prefix}-workspace-aks-development"
  location            = "${azurerm_resource_group.rg_aks_development.location}"
  resource_group_name = "${azurerm_resource_group.rg_aks_development.name}"
  sku                 = "pergb2018"
}

resource "azurerm_log_analytics_solution" "solution_aks_development" {
  solution_name         = "ContainerInsights"
  location              = "${azurerm_resource_group.rg_aks_development.location}"
  resource_group_name   = "${azurerm_resource_group.rg_aks_development.name}"
  workspace_resource_id = "${azurerm_log_analytics_workspace.workspace_aks_development.id}"
  workspace_name        = "${azurerm_log_analytics_workspace.workspace_aks_development.name}"

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}
