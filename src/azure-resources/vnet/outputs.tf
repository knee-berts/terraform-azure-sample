output "vnet_subnets" {
  description = "The ids of subnets created inside the new vNet"
  value       = "${azurerm_subnet.subnet.*.id}"
}
