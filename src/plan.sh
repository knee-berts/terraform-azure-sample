set -e
###############################################################
# Script Parameters                                           #
###############################################################
EXECUTE=false
# while getopts a:e:f:g:m:p:r:s:z: option
while getopts a:e:f:g:m:p:r:s:t:v:z: option
do
    case "${option}"
    in
    a) STORAGE_ACCOUNT_NAME=${OPTARG};;
    e) ENVIRONMENT=${OPTARG};;
    f) SUMMARY_FILE=${OPTARG};;
    g) RESOURCE_GROUP_NAME=${OPTARG};;
    m) USE_MSI=${OPTARG};;
    p) PLAN_PATH=${OPTARG};;
    r) REFRESH=${OPTARG};;
    s) TFVARS_FILE=${OPTARG};;
    t) TFVARS_SECRET=${OPTARG};;
    v) KEYVAULT_NAME=${OPTARG};;
    z) TF_PARAMS=${OPTARG};;
    esac
done

if [ -z "$STORAGE_ACCOUNT_NAME" ]; then
    echo "-a is a required argument - STORAGE_ACCOUNT_NAME"
    exit 1
fi
if [ -z "$ENVIRONMENT" ]; then
    echo "-e is a required argument - ENVIRONMENT (dev, prod)"
    exit 1
fi
if [ -z "$TFVARS_FILE" ]; then
    echo "TFVARS_FILE not set. Defaulting to use /mnt/secrets/terraform.tfvars"
    TFVARS_FILE="/mnt/secrets/terraform.tfvars"
fi
if [ -z "$USE_MSI" ]; then
    echo "USE_MSI not set. Defaulting to use MSI auth"
    USE_MSI="true"
fi
if [ -z "$PLAN_PATH" ]; then
    echo "PLAN_PATH not set."
fi
if [ -z "$SUMMARY_FILE" ]; then
    echo "SUMMARY_FILE not set. Defaulting to /dev/null"
    SUMMARY_FILE=/dev/null
fi
if [ -z "$TFVARS_SECRET" ]; then
    echo "-t is a required argument - Keyvault secret name for .tfvars file"
    exit 1
fi
if [ -z "$KEYVAULT_NAME" ]; then
    echo "-v is a required argument - Keyvault name"
    exit 1
fi

###############################################################
# Script Begins                                               #
###############################################################
set -x
CURRENT_PATH="$(dirname "$0")"
. $CURRENT_PATH/init.sh -g $RESOURCE_GROUP_NAME -a $STORAGE_ACCOUNT_NAME -e $ENVIRONMENT

# Pull down .tfvars to tmpfs from Azure Key Vault
az keyvault secret show -n $TFVARS_SECRET --vault-name $KEYVAULT_NAME
if [ $? -ne 0 ]
then
    echo "Keyvault secret $TFVARS_SECRET in Keyvault $KEYVAULT_NAME does not exist"
    exit 1
else
    az keyvault secret download -f $TFVARS_FILE -n $TFVARS_SECRET --vault-name $KEYVAULT_NAME
fi

# get subscrption info
SUBSCRIPTION_ID=$(az account show --query id --out tsv)
TENANT_ID=$(az account show --query tenantId --out tsv)

# refresh the infra if needed
if [ "$REFRESH" = "true" ]
then
    echo "Refreshing state from actual infrastructure..." 

    terraform refresh -var-file=$TFVARS_FILE \
        -var "environment=$ENVIRONMENT" \
        -var "use_msi=$USE_MSI" \
        -var "tenant=$TENANT_ID" \
        -var "subscription=$SUBSCRIPTION_ID" \
        -var "agent_hostname=$(hostname)" \
        $CURRENT_PATH

    # terraform refresh \
    # -var "use_msi=$USE_MSI" \
    # -var "tenant=$TENANT_ID" \
    # -var "subscription=$SUBSCRIPTION_ID" \
    # -var "environment=$ENVIRONMENT" \
    # -var "dev_suffix=$DEV_SUFFIX" \
    # -var "agent_hostname=$(hostname)" \
    # $CURRENT_PATH

fi

set -e
# validate the files
terraform validate -var-file=$TFVARS_FILE \
    -var "environment=$ENVIRONMENT" \
    -var "use_msi=$USE_MSI" \
    -var "tenant=$TENANT_ID" \
    -var "subscription=$SUBSCRIPTION_ID" \
    -var "agent_hostname=$(hostname)" \
    $CURRENT_PATH

# terraform validate \
#     -var "use_msi=$USE_MSI" \
#     -var "tenant=$TENANT_ID" \
#     -var "subscription=$SUBSCRIPTION_ID" \
#     -var "environment=$ENVIRONMENT" \
#     -var "dev_suffix=$DEV_SUFFIX" \
#     -var "agent_hostname=$(hostname)" \
#     $CURRENT_PATH


echo "Planning upgrade..."

if [ -z "$PLAN_PATH" ]; then
    PLAN_PATH=/dev/null
fi

terraform plan -var-file=$TFVARS_FILE \
    -out=$PLAN_PATH \
    -var "environment=$ENVIRONMENT" \
    -var "use_msi=$USE_MSI" \
    -var "tenant=$TENANT_ID" \
    -var "subscription=$SUBSCRIPTION_ID" \
    -var "agent_hostname=$(hostname)" \
    -no-color \
    $TF_PARAMS \
    $CURRENT_PATH | tee $SUMMARY_FILE

# terraform plan \
#     -out=$PLAN_PATH \
#     -var "use_msi=$USE_MSI" \
#     -var "tenant=$TENANT_ID" \
#     -var "subscription=$SUBSCRIPTION_ID" \
#     -var "environment=$ENVIRONMENT" \
#     -var "dev_suffix=$DEV_SUFFIX" \
#     -var "agent_hostname=$(hostname)" \
#     -no-color \
#     $TF_PARAMS \
#     $CURRENT_PATH | tee $SUMMARY_FILE

set +e
