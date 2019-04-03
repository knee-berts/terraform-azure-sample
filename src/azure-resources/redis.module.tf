# module "redis" {
#   source = "./redis"

#   redis_name          = "${var.redis_name}"
#   resource_group_name = "${var.redis_resource_group_name}"
#   location            = "${var.location}"
#   redis_subnet_id     = "${module.vnet.vnet_subnets[1]}"
# }
