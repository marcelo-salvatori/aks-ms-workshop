#!/bin/bash

#all variables in the script were set as Envirionment Variables in ~/.profile
az acr create \
    --resource-group $RESOURCE_GROUP \
    --location $REGION_NAME \
    --name $ACR_NAME \
    --sku Standard

git clone https://github.com/MicrosoftDocs/mslearn-aks-workshop-ratings-api.git

cd mslearn-aks-workshop-ratings-api
#this creates acrmfscounsulting.azurecr.io/ratings-api:v1 on ACR repositories

az acr build \
    --registry $ACR_NAME \
    --image ratings-api:v1 .

cd ~

git clone https://github.com/MicrosoftDocs/mslearn-aks-workshop-ratings-web.git

cd mslearn-aks-workshop-ratings-web

az acr build \
    --registry $ACR_NAME \
    --image ratings-web:v1 .

az acr repository list \
    --name $ACR_NAME \
    --output table

az aks update \
    --name $AKS_CLUSTER_NAME \
    --resource-group $RESOURCE_GROUP \
    --attach-acr $ACR_NAME
