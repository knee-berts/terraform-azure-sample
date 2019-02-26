module "vnet" {
  source = "./vnet"

  vnet_name           = "${var.vnet_name}"
  resource_group_name = "${var.vnet_resource_group_name}"
  location            = "${var.location}"
  address_space       = "${var.address_space}"
  subnet_prefixes     = ["${var.subnet_prefixes}"]
  subnet_names        = ["${var.subnet_names}"]
  dns_servers         = "${var.dns_servers}"
  tags                = "${var.tags}"
}
