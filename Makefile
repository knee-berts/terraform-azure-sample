# changing the next variable is required, others can be updated per your preference
PROJECT_NAME=changeme

STORAGE_ACCOUNT_NAME=tfstate${PROJECT_NAME}
ENVIRONMENT=local-dev${PROJECT_NAME}
RESOURCE_GROUP_NAME=tfdev${PROJECT_NAME}
SERVICE_APP_NAME=k8sServ${PROJECT_NAME}
CLIENT_APP_NAME=k8sClient${PROJECT_NAME}
KEYVAULT_NAME=tf${PROJECT_NAME}
SUMMARY_FILE=dev.plan.summary
USE_MSI=false
PLAN_PATH=dev.local.tfplan
REFRESH=true
TFVARS_FILE=./terraform.tfvars
TFVARS_SECRET=tf${PROJECT_NAME}

jq-check: 
	@command -v jq >/dev/null 2>&1 || { echo >&2 "I require jq but it's not installed.  Aborting."; exit 1; }

init: jq-check
	-cd ./src && \
	./init.sh \
	-a ${STORAGE_ACCOUNT_NAME} \
	-e ${ENVIRONMENT} \
	-g ${RESOURCE_GROUP_NAME} \
	-s ${SERVICE_APP_NAME} \
	-c ${CLIENT_APP_NAME} \
	-v ${KEYVAULT_NAME} \
	-t ${TFVARS_SECRET} 

plan:
	-cd ./src && \
	./plan.sh \
	-a ${STORAGE_ACCOUNT_NAME} \
	-e ${ENVIRONMENT} \
	-g ${RESOURCE_GROUP_NAME} \
	-c ${CLIENT_APP_NAME} \
	-v ${KEYVAULT_NAME} \
	-t ${TFVARS_SECRET} \
	-f ${SUMMARY_FILE} \
	-m ${USE_MSI} \
	-p ${PLAN_PATH} \
	-r ${REFRESH} \
	-s ${SERVICE_APP_NAME} \
	-y ${TFVARS_FILE} 
		

apply:
	-cd ./src && \
	./tfapply.sh \
		-p ${PLAN_PATH} 

help:
	cat Makefile

