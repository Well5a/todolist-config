#!/bin/bash

MK_NAMESPACE=todo-application

# Make sure to use local Minikube installation
kubectl config use-context minikube	

# Create the namespace
kubectl create ns ${MK_NAMESPACE}

# Create the application resources 
kubectl apply -f ./kubernetes/

# Create the configmaps from files
kubectl create configmap postgres-exporter-conf \
--namespace=${MK_NAMESPACE} \
--from-file=../../config/queries.yml 

kubectl create configmap init-db-conf \
--namespace=${MK_NAMESPACE} \
--from-file=../../config/initdb.sh 

kubectl create configmap inspectit-conf \
--namespace=${MK_NAMESPACE} \
--from-file=../../config/inspectit/inspectit-http-config.yml 

kubectl config set-context $(kubectl config current-context) --namespace=${MK_NAMESPACE}
