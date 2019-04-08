while getopts g:c:v:t: option
do
    case "${option}"
    in
    g) RESOURCE_GROUP_NAME=${OPTARG};;
    c) CLIENT_APP_NAME=${OPTARG};;
    v) KEYVAULT_NAME=${OPTARG};;
    t) TFVARS_SECRET=${OPTARG};;
    esac
done

if [ -z "$RESOURCE_GROUP_NAME" ]; then
    echo "-g is a required argument - Resource Group Name for storage account"
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

# Create resource group
if [ $(az group exists -n $RESOURCE_GROUP_NAME -o tsv) = false ]
then
    az group create --name $RESOURCE_GROUP_NAME --location eastus2
else
    echo "Resource Group $RESOURCE_GROUP_NAME already exists"
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
    client_id="${CLIENT_ID}"
    client_secret="${CLIENT_SECRET}"
    tenant_id="${TENANT_ID}"
EOF

# put secrets in keyvault
az keyvault secret show -n ${TFVARS_SECRET} --vault-name ${KEYVAULT_NAME}
if [ $? -ne 0 ]
then
    az keyvault create --name ${KEYVAULT_NAME} --resource-group ${RESOURCE_GROUP_NAME} --location eastus2
    # az keyvault create --name tf-keyvault- -resource-group tf-dev --location eastus2
    az keyvault secret set --vault-name ${KEYVAULT_NAME} --name ${TFVARS_SECRET} -f ./temp.tfvars
    # az keyvault secret set --vault-name tf-keyvault234 --name tfkubecagain2 -f ./temp.tfvars
else
    echo "Keyvault secret ${TFVARS_SECRET} in Keyvault $KEYVAULT_NAME already exists -- please validate the values against temp.tfvars"
fi

