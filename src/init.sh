#!/bin/bash
set -e
###############################################################
# Script Parameters                                           #
###############################################################

while getopts a:e:g:s:c:v:t: option
do
    case "${option}"
    in
    a) STORAGE_ACCOUNT_NAME=${OPTARG};;
    e) ENVIRONMENT=${OPTARG};;
    g) RESOURCE_GROUP_NAME=${OPTARG};;
    s) SERVICE_APP_NAME=${OPTARG};;
    c) CLIENT_APP_NAME=${OPTARG};;
    v) KEYVAULT_NAME=${OPTARG};;
    t) TFVARS_SECRET=${OPTARG};;
    esac
done

if [ -z "$RESOURCE_GROUP_NAME" ]; then
    echo "-g is a required argument - Resource Group Name for storage account"
    exit 1
fi
if [ -z "$STORAGE_ACCOUNT_NAME" ]; then
    echo "-a is a required argument - Storage account name"
    exit 1
fi
if [ -z "$ENVIRONMENT" ]; then
    echo "-e is a required argument - Environment (dev, prod)"
    exit 1
fi
if [ -z "$SERVICE_APP_NAME" ]; then
    echo "-s is a required argument - Server Application Name"
    exit 1
fi
if [ -z "$CLIENT_APP_NAME" ]; then
    echo "-c is a required argument - Client Application Name"
    exit 1
fi
if [ -z "$KEYVAULT_NAME" ]; then
    echo "-v is a required argument - KeyVault Name"
    exit 1
fi
if [ -z "$TFVARS_SECRET" ]; then
    echo "-t is a required argument - Tfvars secret"
    exit 1
fi

###############################################################
# Script Begins                                               #
###############################################################

set +e # errors don't matter

# Create resource group
if [ $(az group exists -n $RESOURCE_GROUP_NAME -o tsv) = false ]   
then
    az group create --name $RESOURCE_GROUP_NAME --location eastus2
else 
    echo "Resource Group $RESOURCE_GROUP_NAME already exists"
fi

# Create storage account
az storage account show -n $STORAGE_ACCOUNT_NAME -g $RESOURCE_GROUP_NAME > /dev/null
if [ $? -eq 0 ]
then
    echo "Storage account $STORAGE_ACCOUNT_NAME in resource group $RESOURCE_GROUP_NAME already exists"
else 
    az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob
fi

set -e # errors matter again

# Get storage account key
ACCOUNT_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query [0].value -o tsv)

# Create blob container
az storage container create --name $ENVIRONMENT --account-name $STORAGE_ACCOUNT_NAME --account-key $ACCOUNT_KEY

set +e # errors don't matter

if [ $(az ad app list --display-name ${SERVICE_APP_NAME} | jq '. | length') -gt 0 ]
then
    echo "Service app ${SERVICE_APP_NAME} already exists"
else
    SERVER_APP_URL="http://${SERVICE_APP_NAME}"
    SERVER_APP_SECRET="$(cat /dev/urandom | tr -dc 'A-Za-z0-9!#$%&()*+,-./:;<=>?@[\]^_{|}~' | fold -w 32 | head -n 1)"

    # create the Azure Active Directory server application
    echo "Creating server application..."
    az ad app create --display-name ${SERVICE_APP_NAME} \
        --password "${SERVER_APP_SECRET}" \
        --identifier-uris "${SERVER_APP_URL}" \
        --reply-urls "${SERVER_APP_URL}" \
        --homepage "${SERVER_APP_URL}" \
        --required-resource-accesses @manifest-server.json


    SERVER_APP_ID=$(az ad app list --display-name ${SERVICE_APP_NAME} --output json | jq -r '.[0].appId')

    SERVER_APP_OAUTH_ID=$(az ad app show --id ${SERVER_APP_ID} | jq -r '.oauth2Permissions[0]'.id)

    # update the application
    # open issue on this - https://github.com/Azure/azure-cli/issues/7283
    # manually update via poratl
    az ad app update --id ${SERVER_APP_ID} --set groupMembershipClaims=All

    # create service principal for the server application
    echo "Creating service principal for server application..."
    az ad sp create --id ${SERVER_APP_ID}

    # grant permissions to server application
    echo "Granting permissions to the server application..."
    SERVER_APP_API_IDS=$(az ad app permission list --id $SERVER_APP_ID --query [].resourceAppId --out tsv | xargs echo)
    for RESOURCE_API_ID in $SERVER_APP_API_IDS;
    do
    if [ "$RESOURCE_API_ID" == "00000002-0000-0000-c000-000000000000" ]
    then
        az ad app permission grant --api $RESOURCE_API_ID --id $SERVER_APP_ID --scope "User.Read"
    elif [ "$RESOURCE_API_ID" == "00000003-0000-0000-c000-000000000000" ]
    then
        az ad app permission grant --api $RESOURCE_API_ID --id $SERVER_APP_ID --scope "Directory.Read.All"
    else
        az ad app permission grant --api $RESOURCE_API_ID --id $SERVER_APP_ID --scope "user_impersonation"
    fi
    done

    echo "The Azure Active Directory application has been created. You need to ask an Azure AD Administrator to go the Azure portal an click the Grant permissions button for this app."
fi

if [ $(az ad sp list --display-name ${CLIENT_APP_NAME} | jq '. | length') -gt 0 ]
then 
    echo "Client app ${CLIENT_APP_NAME} already exists"
else
    # Create Role
    SUBSCRIPTION_ID=$(az account show --query id --out tsv)

        # load environment variables
    CLIENT_APP_NAME="${CLIENT_APP_NAME}"
    CLIENT_APP_URL="http://${CLIENT_APP_NAME}"

    # generate manifest for client application
    cat > ./manifest-client.json << EOF
[
    {
    "resourceAppId": "${SERVER_APP_ID}",
    "resourceAccess": [
        {
        "id": "${SERVER_APP_OAUTH_ID}",
        "type": "Scope"
        }
    ]
    }
]
EOF

    echo "client application creation"
    az ad app create --display-name ${CLIENT_APP_NAME} \
        --native-app \
        --required-resource-accesses @manifest-client.json


    CLIENT_APP_ID=$(az ad app list --display-name ${CLIENT_APP_NAME} --query [].appId -o tsv)

    echo "creating sp for ${CLIENT_APP_ID}"
    # create service principal for the client application
    az ad sp create --id ${CLIENT_APP_ID}


    # remove manifest-client.json
    rm ./manifest-client.json

    # grant permissions to server application
    CLIENT_APP_RESOURCES_API_IDS=$(az ad app permission list --id $CLIENT_APP_ID --query [].resourceAppId --out tsv | xargs echo)
    for RESOURCE_API_ID in $CLIENT_APP_RESOURCES_API_IDS;
    do
    az ad app permission grant --api $RESOURCE_API_ID --id $CLIENT_APP_ID
    done
fi

TENANT_ID=$(az account show --query tenantId --out tsv)

if [ $(az ad sp list --display-name "${CLIENT_APP_NAME}-rbac" | jq '. | length') -gt 0 ]
then
    echo "RBAC client app ${CLIENT_APP_NAME}-rbac already exists"
else
    sp_vars=$(az ad sp create-for-rbac -n "${CLIENT_APP_NAME}-rbac" | jq '[.appId, .password]')
    CLIENT_ID=$(echo $sp_vars |  jq -r '.[0]')
    CLIENT_SECRET=$(echo $sp_vars |  jq -r '.[1]')
fi

cat > ./temp.tfvars << EOF
    server_app_id="${SERVER_APP_ID}"
    server_app_secret="${SERVER_APP_SECRET}"
    client_app_id="${CLIENT_APP_ID}"
    client_id="${CLIENT_ID}"
    client_secret="${CLIENT_SECRET}"
    tenant_id="${TENANT_ID}"
EOF

# put secrets in keyvault
az keyvault secret show -n ${TFVARS_SECRET} --vault-name ${KEYVAULT_NAME}
# az keyvault secret show -n tfkubecagain2 --vault-name tf-keyvault
if [ $? -ne 0 ]
then
    az keyvault create --name ${KEYVAULT_NAME} --resource-group ${RESOURCE_GROUP_NAME} --location eastus2
    # az keyvault create --name tf-keyvault- -resource-group tf-dev --location eastus2
    az keyvault secret set --vault-name ${KEYVAULT_NAME} --name ${TFVARS_SECRET} -f ./temp.tfvars
    # az keyvault secret set --vault-name tf-keyvault234 --name tfkubecagain2 -f ./temp.tfvars
else
    echo "Keyvault secret ${TFVARS_SECRET} in Keyvault $KEYVAULT_NAME already exists -- please validate the values against temp.tfvars"
fi

# remove temporary secrets file
rm ./temp.tfvars

set -e 

terraform init \
    -backend-config="access_key=$ACCOUNT_KEY" \
    -backend-config="resource_group_name=$RESOURCE_GROUP_NAME" \
    -backend-config="storage_account_name=$STORAGE_ACCOUNT_NAME" \
    -backend-config="container_name=$ENVIRONMENT" 

echo "init.sh finished"
