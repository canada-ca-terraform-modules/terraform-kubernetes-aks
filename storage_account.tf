# Storage Accounts

resource "azurerm_storage_account" "sa_vault" {
  name                     = "${replace(var.short_prefix, "-", "")}vault"
  location                 = azurerm_resource_group.rg_aks.location
  resource_group_name      = azurerm_resource_group.rg_aks.name
  account_tier             = "Standard"
  account_kind             = "StorageV2"
  account_replication_type = "LRS"
  # enable_blob_encryption = "True"
  # enable_file_encryption = "True"
  access_tier               = "Hot"
  enable_https_traffic_only = true
}

resource "azurerm_storage_container" "sc_vault" {
  name                  = "vault"
  storage_account_name  = azurerm_storage_account.sa_vault.name
  container_access_type = "private"
}

resource "azurerm_storage_account" "sa_velero" {
  name                     = "${replace(var.short_prefix, "-", "")}velero"
  location                 = azurerm_resource_group.rg_aks.location
  resource_group_name      = azurerm_resource_group.rg_aks.name
  account_tier             = "Standard"
  account_kind             = "StorageV2"
  account_replication_type = "LRS"
  # enable_blob_encryption = "True"
  # enable_file_encryption = "True"
  access_tier               = "Hot"
  enable_https_traffic_only = true
}

resource "azurerm_storage_container" "sc_velero" {
  name                  = "velero"
  storage_account_name  = azurerm_storage_account.sa_velero.name
  container_access_type = "private"
}
