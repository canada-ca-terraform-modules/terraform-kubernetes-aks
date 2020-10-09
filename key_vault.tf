# Key Vault

resource "azurerm_key_vault" "vault" {
  name                        = "${var.short_prefix}-vault"
  location                    = "${azurerm_resource_group.rg_vault.location}"
  resource_group_name         = "${azurerm_resource_group.rg_vault.name}"
  enabled_for_disk_encryption = true
  tenant_id                   = "${var.tenant_id}"

  sku_name = "standard"

  access_policy {
    tenant_id = "${var.tenant_id}"
    object_id = "${azurerm_user_assigned_identity.vault.principal_id}"

    key_permissions = [
      "get",
      "list",
      "update",
      "create",
      "import",
      "delete",
      "recover",
      "backup",
      "restore",
      "wrapKey",
      "unwrapKey",
    ]

    secret_permissions = []

    storage_permissions = []
  }

  access_policy {
    tenant_id = "${var.tenant_id}"
    object_id = "${data.azurerm_client_config.current.object_id}"

    key_permissions = [
      "get",
      "list",
      "update",
      "create",
      "import",
      "delete",
      "recover",
      "backup",
      "restore",
      "wrapKey",
      "unwrapKey",
    ]

    secret_permissions = []

    storage_permissions = []
  }

}

resource "azurerm_key_vault_key" "generated" {
  name         = "vault"
  key_vault_id = "${azurerm_key_vault.vault.id}"
  key_type     = "RSA"
  key_size     = 4096

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}
