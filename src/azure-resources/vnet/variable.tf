variable "vnet_name" {
  description = "Name of the vnet to create"
  default     = "vnet-aks-eastus"
}

variable "resource_group_name" {
  description = "Default resource group name that the network will be created in."
  default     = "rg-aks-networking"
}

variable "location" {
  description = "The location/region where the core network will be created. The full list of Azure regions can be found at https://azure.microsoft.com/regions"
  default     = "eastus2"
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

variable "tags" {
  description = "The tags to associate with your network and subnets."
  type        = "map"

  default = {
    source      = "terraform"
    environment = "demo"
    purpose     = "aksdemo"
  }
}
