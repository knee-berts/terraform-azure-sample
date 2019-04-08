provider "azurerm" {
  version         = ">=1.12.0"
  use_msi         = "${var.use_msi}"
  tenant_id       = "${var.tenant}"
  subscription_id = "${var.subscription}"
}

provider "random" {
  version = "~> 2.0"
}

# Configure the Microsoft Azure AD Provider
provider "azuread" {
  subscription_id = "${var.subscription}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant}"
}