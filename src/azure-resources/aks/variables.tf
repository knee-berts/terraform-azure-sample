# Service Principal Configurations
variable "client_id" {}

variable "client_secret" {}

# AAD RBAC Congirurations
variable "client_app_id" {
  default = "placeholder"
}

variable "server_app_id" {
  default = "placeholder"
}

variable "server_app_secret" {
  default = "placeholder"
}

# AKS Configurations
variable "agent_count" {
  default = 3
}

variable "kubernetes_version" {
  default = "1.12.4"
}

// variable "ssh_public_key" {
//   default = "~/.ssh/id_rsa.pub"
// }

variable "dns_prefix" {
  default = "aks-demo"
}

variable "cluster_name" {
  default = "aks-demo"
}

variable "resource_group_name" {
  default = "rg-aks"
}

variable "location" {
  default = "eastus2"
}

variable "agentpool_subnet_id" {}

variable "network_plugin" {
  default = "azure"
}

variable "dns_service_ip" {
  default = "10.3.0.10"
}

variable "docker_bridge_cidr" {
  default = "172.17.0.1/16"
}

variable "service_cidr" {
  default = "10.3.0.0/16"
}

# Azure Container Insights Configurations
variable "log_analytics_workspace_name" {
  default = "AKSLogAnalyticsWorkspace"
}

# refer https://azure.microsoft.com/global-infrastructure/services/?products=monitor for log analytics available regions
variable "log_analytics_workspace_location" {
  default = "eastus"
}

# refer https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing 
variable "log_analytics_workspace_sku" {
  default = "PerGB2018"
}

# Tags applied throughout 
variable "tags" {
  description = "The tags to associate with AKS and dependencies."
  type        = "map"

  default = {
    source      = "terraform"
    environment = "demo"
    purpose     = "aksdemo"
  }
}
