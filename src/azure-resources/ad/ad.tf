# Create an Azure Active Directory Application
resource "azuread_application" "svc" {
  name                       = "${var.cluster_name}-svc"
  homepage                   = "https://homepage"
  identifier_uris            = ["https://uri"]
  reply_urls                 = ["https://replyurl"]
  available_to_other_tenants = false
  oauth2_allow_implicit_flow = true
  password = "${var.server_app_secret}"

    required_resource_access {
        resourceAppId= "00000003-0000-0000-c000-000000000000"
    
        resourceAccess {
            id="7ab1d382-f21e-4acd-a863-ba3e13f7da61"
            type="Role"
            }

        resourceAccess {
            id="06da0dbc-49e2-44d2-8312-53f166ab848a"
            type="Scope"
            }

        resourceAccess {
            id="e1fe6dd8-ba31-4d61-89e7-88639da4683d"
            type="Scope"
            }
    }

    required_resource_access {
        resourceAppId= "00000002-0000-0000-c000-000000000000"
    
        resourceAccess {
            id="311a71cc-e848-46a1-bdf8-97ff7156d8e6"
            type="Role"
            }
    }
}

#     az ad app update --id ${SERVER_APP_ID} --set groupMembershipClaims=All
#     # grant permissions to server application
#     echo "Granting permissions to the server application..."
#     SERVER_APP_API_IDS=$(az ad app permission list --id $SERVER_APP_ID --query [].resourceAppId --out tsv | xargs echo)
#     for RESOURCE_API_ID in $SERVER_APP_API_IDS;
#     do
#     if [ "$RESOURCE_API_ID" == "00000002-0000-0000-c000-000000000000" ]
#     then
#         az ad app permission grant --api $RESOURCE_API_ID --id $SERVER_APP_ID --scope "User.Read"
#     elif [ "$RESOURCE_API_ID" == "00000003-0000-0000-c000-000000000000" ]
#     then
#         az ad app permission grant --api $RESOURCE_API_ID --id $SERVER_APP_ID --scope "Directory.Read.All"
#     else
#         az ad app permission grant --api $RESOURCE_API_ID --id $SERVER_APP_ID --scope "user_impersonation"
#     fi
#     done
## TODO: add this

# az ad sp create --id ${SERVER_APP_ID}
# Create a service principal
resource "azuread_service_principal" "svc" {
  application_id = "${azuread_application.svc.application_id}"
}

## CLIENT STUFF Below

resource "azuread_application" "client" {
  name                       = "${var.cluster_name}-client"
  homepage                   = "https://homepage"
  identifier_uris            = ["https://uri"]
  reply_urls                 = ["https://replyurl"]
  available_to_other_tenants = false
  oauth2_allow_implicit_flow = true
  password = "${var.server_app_secret}"


  #     "resourceAppId": "${SERVER_APP_ID}",
#     "resourceAccess": [
#         {
#         "id": "${SERVER_APP_OAUTH_ID}",
#         "type": "Scope"
#         }
#     ]

 # --native-app \

    required_resource_access {
        resourceAppId= "00000003-0000-0000-c000-000000000000"
    
        resourceAccess {
            id="7ab1d382-f21e-4acd-a863-ba3e13f7da61"
            type="Role"
            }

        resourceAccess {
            id="06da0dbc-49e2-44d2-8312-53f166ab848a"
            type="Scope"
            }

        resourceAccess {
            id="e1fe6dd8-ba31-4d61-89e7-88639da4683d"
            type="Scope"
            }
    }

    required_resource_access {
        resourceAppId= "00000002-0000-0000-c000-000000000000"
    
        resourceAccess {
            id="311a71cc-e848-46a1-bdf8-97ff7156d8e6"
            type="Role"
            }
    }
}

#     # grant permissions to server application
#     CLIENT_APP_RESOURCES_API_IDS=$(az ad app permission list --id $CLIENT_APP_ID --query [].resourceAppId --out tsv | xargs echo)
#     for RESOURCE_API_ID in $CLIENT_APP_RESOURCES_API_IDS;
#     do
#     az ad app permission grant --api $RESOURCE_API_ID --id $CLIENT_APP_ID
#     done


# az ad sp create-for-rbac -n "${CLIENT_APP_NAME}-rbac" | jq '[.appId, .password]')


# cat > ./temp.tfvars << EOF
#     server_app_id="${SERVER_APP_ID}"
#     server_app_secret="${SERVER_APP_SECRET}"
#     client_app_id="${CLIENT_APP_ID}"
#     client_id="${CLIENT_ID}"
#     client_secret="${CLIENT_SECRET}"
#     tenant_id="${TENANT_ID}"
# EOF
