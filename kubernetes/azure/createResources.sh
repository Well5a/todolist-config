#!/bin/bash

# Change these parameters as needed for your own environment
AKS_STORAGE_ACCOUNT_NAME=mwe
AKS_RESOURCE_GROUP=mwe-monitoring
AKS_LOCATION=westeurope
AKS_SHARE_NAME=monitoring-share
AKS_CLUSTER_NAME=monitoring-cluster
AKS_NAMESPACE=todo-application

# Create a resource group
az group create \
--name ${AKS_RESOURCE_GROUP} \
--location ${AKS_LOCATION}

# Create a storage account
az storage account create \
-n ${AKS_STORAGE_ACCOUNT_NAME} \
-g ${AKS_RESOURCE_GROUP} \
-l ${AKS_LOCATION} \
--sku Standard_LRS

# Get the connection string as an environment variable, this is used when creating the Azure file share
AZURE_STORAGE_CONNECTION_STRING=$(az storage account show-connection-string -n ${AKS_STORAGE_ACCOUNT_NAME} -g ${AKS_RESOURCE_GROUP} -o tsv)

# Create the file share
az storage share create \
-n ${AKS_SHARE_NAME} \
--connection-string ${AZURE_STORAGE_CONNECTION_STRING}

# Get storage account key
STORAGE_KEY=$(az storage account keys list --resource-group ${AKS_RESOURCE_GROUP} --account-name ${AKS_STORAGE_ACCOUNT_NAME} --query "[0].value" -o tsv)

# Upload Files - change the source to the location of your dashboard files
az storage file upload-batch \
--source "../../grafana/provisioning/dashboards" \
--account-name ${AKS_STORAGE_ACCOUNT_NAME} \
--account-key ${STORAGE_KEY} \
--destination ${AKS_SHARE_NAME}

# Create the Kubernetes cluster
az aks create \
--resource-group=${AKS_RESOURCE_GROUP} \
--name=${AKS_CLUSTER_NAME} \
--dns-name-prefix=monitoring \
--node-count=1 \
--generate-ssh-keys \
--kubernetes-version=1.12.7 \
--location=${AKS_LOCATION}

# install kubectl for azure cli (only necessary the first time)
# sudo az aks install-cli

# set the cluster as the current instance for kubectl
az aks get-credentials \
--resource-group=${AKS_RESOURCE_GROUP} \
--name=${AKS_CLUSTER_NAME}

# Create the namespace
kubectl create ns ${AKS_NAMESPACE}

# Create the secret for the Grafana dashboards file share
kubectl create secret generic todo-grafana-secret \
--namespace ${AKS_NAMESPACE} \
--from-literal=azurestorageaccountname=${AKS_STORAGE_ACCOUNT_NAME} \
--from-literal=azurestorageaccountkey=${STORAGE_KEY}

# Create the application resources
kubectl apply -f ./kubernetes/

# Create the configmaps from files
kubectl create configmap postgres-exporter-conf \
--namespace=${AKS_NAMESPACE} \
--from-file=../../config/queries.yml 

kubectl create configmap init-db-conf \
--namespace=${AKS_NAMESPACE} \
--from-file=../../config/initdb.sh 

kubectl create configmap inspectit-conf \
--namespace=${AKS_NAMESPACE} \
--from-file=../../config/inspectit/inspectit-http-config.yml

# set the default namespace
kubectl config set-context $(kubectl config current-context) --namespace=${AKS_NAMESPACE}