#!/bin/bash

# Delete the ressource group and all associated ressources
az group delete --name mwe-monitoring

# Delete the cluster information from kubectl
kubectl config unset users.clusterUser_mwe-monitoring_monitoring-cluster
kubectl config unset contexts.monitoring-cluster
kubectl config unset clusters.monitoring-cluster
