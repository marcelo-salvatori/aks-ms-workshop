#add environment variable that are going to be used in the scripts
cat << EOF >> ~/.profile
export REGION_NAME=<put the azure region to deploy de aks cluster I.E. westeurope>
export RESOURCE_GROUP=<resource group name where the aks cluster will be deployed>
export SUBNET_NAME=<subnet name for your cluster vnet>
export VNET_NAME=<vnet for your cluster>
export AKS_CLUSTER_NAME=<unique name for you aks cluster>
export ACR_NAME=<unique name for the azure container register>
export mongodbUsername=<a username for the administrator of the mongodb you are going to create on this workshop>
export mongodbPassword=<a password for the user above>
export email=<an email to create a SSL/TLS certificate>
export WORKSPACE=<name for a workspace the is going to be used for log analytics>
EOF

#download the frontend and api for the application
