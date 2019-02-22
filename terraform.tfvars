location="eastus2"
vnet_name="vnet-aks-eastus2-tf"
vnet_resource_group_name="rg-aks-network-tf"
address_space="10.0.0.0/8"
subnet_prefixes=["10.240.0.0/24"]
subnet_names=["aks-agentpool-1"]
client_id="f352484c-167d-4524-b74a-80b7ea9eef8a"
client_secret="e64ea5f4-26f6-46b9-947c-91a173ea0c80"
client_app_id="e6a2edd0-1880-4726-bb91-1101026cc8c0"
server_app_id="cf61d282-c177-4895-971a-cd35a4f4cc76"
server_app_secret="-+=!/>@I(Zx%XnxV|q]fW||f[?dB^%/x.{J2}yc&./+>v}vY+lnFM/wwa[3)8:="
cluster_name="aks-demo-tf"
aks_resource_group_name="rg-aks-tf"
kubernetes_version="1.12.5"
network_plugin="azure"
dns_service_ip="10.3.0.10"
service_cidr="10.3.0.0/16"
log_analytics_workspace_sku="Standalone"
tags={
    source      = "terraform"
    environment = "demo"
    purpose     = "aksdemo-tf"
}


