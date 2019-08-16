# Azure Kubernetes Service

resource "azurerm_kubernetes_cluster" "aks_development" {
  name                = "${var.prefix}-aks-development"
  location            = "${azurerm_resource_group.rg_aks_development.location}"
  resource_group_name = "${azurerm_resource_group.rg_aks_development.name}"
  dns_prefix          = "${var.prefix}-aks-development"

  kubernetes_version  = "1.14.3"

  linux_profile {
    admin_username = "azureuser"

    ssh_key {
      key_data = "${file(var.public_ssh_key_path)}"
    }
  }

  agent_pool_profile {
    name                  = "nodepool1"
    count                 = 2
    vm_size               = "Standard_D8s_v3"
    os_type               = "Linux"
    os_disk_size_gb       = 200
    max_pods              = 60
    vnet_subnet_id        = "${azurerm_subnet.subnet_aks_development.id}"
    type                  = "VirtualMachineScaleSets"
    enable_auto_scaling   = false
    # min_count             = 2
    # max_count             = 50
  }

  service_principal {
    client_id     = "${azuread_application.client.application_id}"
    client_secret = "${azuread_service_principal_password.client.value}"
  }

  addon_profile {
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = "${azurerm_log_analytics_workspace.workspace_aks_development.id}"
    }
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
    docker_bridge_cidr = "172.17.0.1/16"
    dns_service_ip = "10.0.0.10"
    service_cidr = "10.0.0.0/16"
    load_balancer_sku   = "basic"
  }

  role_based_access_control {
    enabled = true

    azure_active_directory {
      client_app_id     = "${azuread_application.client.application_id}"
      server_app_id     = "${azuread_application.server.application_id}"
      server_app_secret = "${azuread_service_principal_password.server.value}"
    }
  }

  tags = {
    Environment = "Development"
  }
}
