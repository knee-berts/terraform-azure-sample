# Generate random text for a unique log analytics workspace
resource "random_id" "randomId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = "${var.resource_group_name}"
  }

  byte_length = 8
}

resource "azurerm_resource_group" "aks" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"
}

resource "azurerm_resource_group" "containerInsights" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"
}

resource "azurerm_log_analytics_workspace" "demo" {
  name                = "${var.log_analytics_workspace_name}${random_id.randomId.hex}"
  location            = "${var.log_analytics_workspace_location}"
  resource_group_name = "${azurerm_resource_group.aks.name}"
  sku                 = "${var.log_analytics_workspace_sku}"
}

resource "azurerm_log_analytics_solution" "demo" {
  solution_name         = "ContainerInsights"
  location              = "${azurerm_log_analytics_workspace.demo.location}"
  resource_group_name   = "${azurerm_resource_group.aks.name}"
  workspace_resource_id = "${azurerm_log_analytics_workspace.demo.id}"
  workspace_name        = "${azurerm_log_analytics_workspace.demo.name}"

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}


resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.cluster_name}"
  location            = "${azurerm_resource_group.aks.location}"
  resource_group_name = "${azurerm_resource_group.aks.name}"
  dns_prefix          = "${var.dns_prefix}"
  kubernetes_version  = "${var.kubernetes_version}"

  // linux_profile {
  //   admin_username = "theadmin"


  //   ssh_key {
  //     key_data = "${file("${var.ssh_public_key}")}"
  //   }
  // }

  agent_pool_profile {
    name            = "agentpool"
    count           = "${var.agent_count}"
    vm_size         = "Standard_DS4_v2"
    os_type         = "Linux"
    os_disk_size_gb = 30
    vnet_subnet_id  = "${var.agentpool_subnet_id}"
  }
  network_profile {
    network_plugin     = "${var.network_plugin}"
    dns_service_ip     = "${var.dns_service_ip}"
    docker_bridge_cidr = "${var.docker_bridge_cidr}"

    # pod_cidr = "${var.pod_cidr}"
    service_cidr = "${var.service_cidr}"
  }
  service_principal {
    client_id     = "${var.client_id}"
    client_secret = "${var.client_secret}"
  }
  role_based_access_control {
    enabled = true

    azure_active_directory {
      client_app_id     = "${var.client_app_id}"
      server_app_id     = "${var.server_app_id}"
      server_app_secret = "${var.server_app_secret}"
    }
  }
  addon_profile {
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = "${azurerm_log_analytics_workspace.demo.id}"
    }
  }
  tags = "${var.tags}"
}
