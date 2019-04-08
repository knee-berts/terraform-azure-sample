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
