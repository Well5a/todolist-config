#!/bin/bash

# Make changes to the dashboards while running the application

# Change these parameters as needed for your own environment
AKS_STORAGE_ACCOUNT_NAME=mwe
AKS_RESOURCE_GROUP=mwe-monitoring
AKS_SHARE_NAME=monitoring-share

# Get storage account key
STORAGE_KEY=$(az storage account keys list --resource-group ${AKS_RESOURCE_GROUP} --account-name ${AKS_STORAGE_ACCOUNT_NAME} --query "[0].value" -o tsv)

# Upload Files - change the source to the location of your dashboard files
az storage file upload-batch \
--source "../../grafana/provisioning/dashboards" \
--account-name ${AKS_STORAGE_ACCOUNT_NAME} \
--account-key ${STORAGE_KEY} \
--destination ${AKS_SHARE_NAME}