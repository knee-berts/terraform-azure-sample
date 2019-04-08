
module "ad" {
  source = "./ad"
  subscription         = "${var.subscription}"
  cluster_name = "${var.cluster_name}"
}


module "aks" {
  source = "./aks"

  client_id          = "${var.client_id}"
  client_secret      = "${var.client_secret}"
  client_app_id      = "${module.ad.client_app_id}"
  server_app_id      = "${module.ad.server_app_id}"
  server_app_secret  = "${module.ad.server_app_secret}"
  agent_count        = "${var.agent_count}"
  kubernetes_version = "${var.kubernetes_version}"

  // ssh_public_key                   = "${var.ssh_public_key}"
  dns_prefix                       = "${var.dns_prefix}"
  cluster_name                     = "${var.cluster_name}"
  resource_group_name              = "${var.aks_resource_group_name}"
  location                         = "${var.location}"
  agentpool_subnet_id              = "${module.vnet.vnet_subnets[0]}"
  network_plugin                   = "${var.network_plugin}"
  dns_service_ip                   = "${var.dns_service_ip}"
  docker_bridge_cidr               = "${var.docker_bridge_cidr}"
  service_cidr                     = "${var.service_cidr}"
  log_analytics_workspace_name     = "${var.log_analytics_workspace_name}"
  log_analytics_workspace_location = "${var.log_analytics_workspace_location}"
  log_analytics_workspace_sku      = "${var.log_analytics_workspace_sku}"
  tags                             = "${var.tags}"
  dependencies = ["${module.ad.client_app_id}",]
}

