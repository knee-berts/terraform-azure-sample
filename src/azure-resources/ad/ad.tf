## derirved from mion00 - https://github.com/terraform-providers/terraform-provider-azuread/issues/67
# AD server application
resource "azuread_application" "svc" {
  name                       = "${var.cluster_name}-svc"
  available_to_other_tenants = false
  # oauth2_allow_implicit_flow = true
  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph API

    # Necessary permissions
    resource_access {
      id   = "7ab1d382-f21e-4acd-a863-ba3e13f7da61" # Read directory data
      type = "Role"
    }

    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d" # Sign in and read user profile
      type = "Scope"
    }

    resource_access {
      id   = "06da0dbc-49e2-44d2-8312-53f166ab848a" # Read directory data permission
      type = "Scope"
    }
  }
}

# External data source to get information about the AADserver AD application
data "external" "AADserver_application" {
  program = ["bash", "azure_ad.sh"]

  query = {
    # arbitrary map from strings to strings, passed to the external program as the data query
    application_id = "${azuread_application.svc.application_id}"
  }

}

# if this isssue is closed, replace with native functionality - https://github.com/terraform-providers/terraform-provider-azuread/issues/67
resource "null_resource" "oauth" {
  provisioner "local-exec" {
    command = ")"
  }
}

data "external" "oauth_id" {
  program = ["bash", "azure_ad.sh"]

  query = {
    # arbitrary map from strings to strings, passed to the external program as the data query
    application_id = "${azuread_application.svc.application_id}"
  }

}

# AD client application
resource "azuread_application" "client" {
  name                       = "${var.cluster_name}-client"
  available_to_other_tenants = false
  oauth2_allow_implicit_flow = true

  # Set reply urls, or the login will fail
  reply_urls = ["https://${var.cluster_name}-client"]

  # Setup access to the AAD server application
  required_resource_access {
    resource_app_id = "${azuread_application.svc.application_id}" # Server AAD application id

    # Necessary permissions
    resource_access {
      id   = "${data.external.oauth_id.result.oauth_id}" # OAUTH2 application ID
      type = "Scope"
    }
  }
}

# Create a service principal
resource "azuread_service_principal" "svc" {
  application_id = "${azuread_application.svc.application_id}"
}

resource "random_string" "password" {
  length  = 32
  special = true
}

resource "azuread_service_principal_password" "svc" {
  service_principal_id = "${azuread_service_principal.svc.id}"
  value                = "${random_string.password.result}"
#   end_date_relative    = "17520h"
}

resource "azurerm_role_assignment" "svc" {
  scope                = "${var.subscription}"
  role_definition_name = "Contributor"
  principal_id         = "${azuread_service_principal.svc.id}"
}

output "server_app_id" {
  value = "${azuread_application.svc.application_id}"
}

output "server_app_secret" {
  value     = "${azuread_service_principal_password.svc.value}"
  sensitive = true
}

output "client_app_id" {
  value = "${azuread_application.client.application_id}"
}