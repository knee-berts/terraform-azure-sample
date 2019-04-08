### Azure ARM Configs ###
variable "use_msi" {
  type        = "string"
  description = "Use MSI to deploy resources"
}

variable "environment" {
  type        = "string"
  description = "Environment, i.e. prod, dev or local"
}

variable "tenant" {
  type        = "string"
  description = "Azure Tenant Id"
}

variable "subscription" {
  type        = "string"
  description = "Azure Subscription Id"
}

variable "agent_hostname" {
  type        = "string"
  description = "Hostname of the terraform agent"
}

### App Services Configs ###

variable "appsvc_location" {
  type        = "string"
  description = "Location of the azure resource group."
  default     = "eastus2"
}

variable "appsvc_name" {
  type        = "string"
  description = "Name of the app service"
}

### Vnet Configs###

variable "vnet_name" {
  description = "Name of the vnet to create"
  default     = "vnet-aks-eastus"
}

variable "vnet_resource_group_name" {
  description = "Default resource group name that the network will be created in."
  default     = "rg-aks-networking"
}

variable "address_space" {
  description = "The address space that is used by the virtual network."
  default     = "10.0.0.0/8"
}

variable "subnet_prefixes" {
  description = "The address prefix to use for the subnet."
  default     = ["10.240.0.0/24"]
}

variable "subnet_names" {
  description = "A list of public subnets inside the vNet."
  default     = ["aks-agentpool-1"]
}

# If no values specified, this defaults to Azure DNS 
variable "dns_servers" {
  description = "The DNS servers to be used with vNet."
  default     = []
}

/* variable "nsg_ids" {
  description = "A map of subnet name to Network Security Group IDs"
  type        = "map"

  default = {
    subnet1 = "nsgid1"
    subnet3 = "nsgid3"
  }
}*/

### AKS Configs ###

# Service Principal Configurations
variable "client_id" {}

variable "client_secret" {}


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

variable "aks_resource_group_name" {
  default = "rg-aks"
}

variable "location" {
  default = "eastus2"
}

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

### Redis Configs ###

variable "redis_name" {
  default = "redis-demo"
}

variable "redis_resource_group_name" {
  default = "rg-aks"
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
