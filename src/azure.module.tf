# comment this module to stop deploying this version
module "azure" {
  source = "./azure-resources"

  tenant         = "${var.tenant}"
  subscription   = "${var.subscription}"
  use_msi        = "${var.use_msi}"
  agent_hostname = "${var.agent_hostname}"
  environment    = "${var.environment}"
  location       = "${var.location}"
  tags           = "${var.tags}"

  appsvc_name = "appsvc-v1${var.dev_suffix}"

  vnet_name                = "${var.vnet_name}"
  vnet_resource_group_name = "${var.vnet_resource_group_name}"
  address_space            = "${var.address_space}"
  subnet_prefixes          = "${var.subnet_prefixes}"
  subnet_names             = "${var.subnet_names}"
  dns_servers              = "${var.dns_servers}"

  client_id                        = "${var.client_id}"
  client_secret                    = "${var.client_secret}"
  client_app_id                    = "${var.client_app_id}"
  server_app_id                    = "${var.server_app_id}"
  server_app_secret                = "${var.server_app_secret}"
  agent_count                      = "${var.agent_count}"
  kubernetes_version               = "${var.kubernetes_version}"
  dns_prefix                       = "${var.dns_prefix}"
  cluster_name                     = "${var.cluster_name}"
  aks_resource_group_name          = "${var.aks_resource_group_name}"
  network_plugin                   = "${var.network_plugin}"
  dns_service_ip                   = "${var.dns_service_ip}"
  docker_bridge_cidr               = "${var.docker_bridge_cidr}"
  service_cidr                     = "${var.service_cidr}"
  log_analytics_workspace_name     = "${var.log_analytics_workspace_name}"
  log_analytics_workspace_location = "${var.log_analytics_workspace_location}"
  log_analytics_workspace_sku      = "${var.log_analytics_workspace_sku}"

  redis_name          = "${var.redis_name}"
  resource_group_name = "${var.redis_resource_group_name}"
  location            = "${var.location}"
}
