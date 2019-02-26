variable "redis_name" {}

variable "resource_group_name" {
  default = "rg-redis"
}

variable "location" {
  default = "eastus2"
}

variable "redis_subnet_id" {}
