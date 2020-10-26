# Azure Active Directory Server

resource "azuread_application" "server" {
  name                    = "k8s_server_${var.prefix}"
  reply_urls              = ["http://k8s_server"]
  type                    = "webapp/api"
  group_membership_claims = "All"

  required_resource_access {
    # Windows Azure Active Directory API
    resource_app_id = "00000002-0000-0000-c000-000000000000"

    resource_access {
      # DELEGATED PERMISSIONS: "Sign in and read user profile":
      id   = "311a71cc-e848-46a1-bdf8-97ff7156d8e6"
      type = "Scope"
    }
  }

  required_resource_access {
    # MicrosoftGraph API
    resource_app_id = "00000003-0000-0000-c000-000000000000"

    # APPLICATION PERMISSIONS: "Read directory data":
    resource_access {
      id   = "7ab1d382-f21e-4acd-a863-ba3e13f7da61"
      type = "Role"
    }

    # DELEGATED PERMISSIONS: "Sign in and read user profile":
    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"
      type = "Scope"
    }

    # DELEGATED PERMISSIONS: "Read directory data":
    resource_access {
      id   = "06da0dbc-49e2-44d2-8312-53f166ab848a"
      type = "Scope"
    }
  }
}

resource "azuread_service_principal" "server" {
  application_id = azuread_application.server.application_id
}

resource "azuread_service_principal_password" "server" {
  service_principal_id = azuread_service_principal.server.id
  value                = random_string.application_server_password.result
  end_date             = timeadd(timestamp(), "87600h") # 10 years

  # The end date will change at each run (terraform apply), causing a new password to
  # be set. So we ignore changes on this field in the resource lifecyle to avoid this
  # behaviour.
  # If the desired behaviour is to change the end date, then the resource must be
  # manually tainted.
  lifecycle {
    ignore_changes = [end_date]
  }
}

# Passwords

resource "random_string" "application_server_password" {
  length  = 16
  special = true

  keepers = {
    service_principal = azuread_service_principal.server.id
  }
}

resource "random_string" "velero_password" {
  length  = 5
  special = false
  upper   = false
}

resource "random_string" "velero_storage_account" {
  length  = 5
  special = false
  upper   = false
}

resource "random_string" "vault_password" {
  length  = 5
  special = false
  upper   = false
}

resource "random_string" "vault_storage_account" {
  length  = 5
  special = false
  upper   = false
}

resource "random_string" "terraform_password" {
  length  = 5
  special = false
  upper   = false
}

# Azure AD Client

resource "azuread_application" "client" {
  name       = "k8s_client_${var.prefix}"
  reply_urls = ["http://k8s_client"]
  type       = "native"

  required_resource_access {
    # Windows Azure Active Directory API
    resource_app_id = "00000002-0000-0000-c000-000000000000"

    resource_access {
      # DELEGATED PERMISSIONS: "Sign in and read user profile":
      id   = "311a71cc-e848-46a1-bdf8-97ff7156d8e6"
      type = "Scope"
    }
  }

  required_resource_access {
    # AKS ad application server
    resource_app_id = azuread_application.server.application_id

    resource_access {
      # Server app Oauth2 permissions id
      id   = lookup(azuread_application.server.oauth2_permissions[0], "id")
      type = "Scope"
    }
  }
}

resource "azuread_service_principal" "client" {
  application_id = azuread_application.client.application_id
}

resource "azuread_service_principal_password" "client" {
  service_principal_id = azuread_service_principal.client.id
  value                = random_string.application_client_password.result
  end_date             = timeadd(timestamp(), "87600h")

  lifecycle {
    ignore_changes = [end_date]
  }
}

resource "random_string" "application_client_password" {
  length  = 16
  special = true

  keepers = {
    service_principal = azuread_service_principal.client.id
  }
}

# Velero

resource "azuread_application" "velero" {
  name                    = "k8s_velero_${var.prefix}"
  reply_urls              = ["http://k8s_velero"]
  type                    = "webapp/api"
  group_membership_claims = "All"

  required_resource_access {
    # Windows Azure Active Directory API
    resource_app_id = "00000002-0000-0000-c000-000000000000"

    resource_access {
      # DELEGATED PERMISSIONS: "Sign in and read user profile":
      id   = "311a71cc-e848-46a1-bdf8-97ff7156d8e6"
      type = "Scope"
    }
  }

  required_resource_access {
    # MicrosoftGraph API
    resource_app_id = "00000003-0000-0000-c000-000000000000"

    # APPLICATION PERMISSIONS: "Read directory data":
    resource_access {
      id   = "7ab1d382-f21e-4acd-a863-ba3e13f7da61"
      type = "Role"
    }

    # DELEGATED PERMISSIONS: "Sign in and read user profile":
    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"
      type = "Scope"
    }

    # DELEGATED PERMISSIONS: "Read directory data":
    resource_access {
      id   = "06da0dbc-49e2-44d2-8312-53f166ab848a"
      type = "Scope"
    }
  }
}

resource "azuread_service_principal" "velero" {
  application_id = azuread_application.velero.application_id
}

resource "azuread_service_principal_password" "velero" {
  service_principal_id = azuread_service_principal.velero.id
  value                = random_string.velero_password.result
  end_date             = timeadd(timestamp(), "87600h") # 10 years

  # The end date will change at each run (terraform apply), causing a new password to
  # be set. So we ignore changes on this field in the resource lifecyle to avoid this
  # behaviour.
  # If the desired behaviour is to change the end date, then the resource must be
  # manually tainted.
  lifecycle {
    ignore_changes = [end_date]
  }
}

# Vault

resource "azuread_application" "vault" {
  name     = "k8s_vault_${var.prefix}"
  homepage = "https://vault.govcloud.ca"
  # reply_urls              = ["https://vault.govcloud.ca/ui/vault/auth/oidc/oidc/callback", "http://localhost:8250/oidc/callback"]
  type                    = "webapp/api"
  group_membership_claims = "All"

  required_resource_access {
    # Windows Azure Active Directory API
    resource_app_id = "00000002-0000-0000-c000-000000000000"

    resource_access {
      # DELEGATED PERMISSIONS: "Read all groups":
      id   = "6234d376-f627-4f0f-90e0-dff25c5211a3"
      type = "Scope"
    }
  }
}

resource "azurerm_user_assigned_identity" "vault" {
  resource_group_name = azurerm_resource_group.rg_aks.name
  location            = azurerm_resource_group.rg_aks.location

  name = "vault"
}

resource "azuread_service_principal" "vault" {
  application_id = azuread_application.vault.application_id
}

resource "azuread_service_principal_password" "vault" {
  service_principal_id = azuread_service_principal.vault.id
  value                = random_string.vault_password.result
  end_date             = timeadd(timestamp(), "87600h") # 10 years

  # The end date will change at each run (terraform apply), causing a new password to
  # be set. So we ignore changes on this field in the resource lifecyle to avoid this
  # behaviour.
  # If the desired behaviour is to change the end date, then the resource must be
  # manually tainted.
  lifecycle {
    ignore_changes = [end_date]
  }
}

# # Terraform Service Principal

# resource "azuread_service_principal" "terraform" {
#   application_id = var.client_id
# }

# resource "azuread_service_principal_password" "terraform" {
#   service_principal_id = azuread_service_principal.terraform.id
#   value                = random_string.terraform_password.result
#   end_date             = timeadd(timestamp(), "87600h") # 10 years

#   # The end date will change at each run (terraform apply), causing a new password to
#   # be set. So we ignore changes on this field in the resource lifecyle to avoid this
#   # behaviour.
#   # If the desired behaviour is to change the end date, then the resource must be
#   # manually tainted.
#   lifecycle {
#     ignore_changes = [end_date]
#   }
# }
