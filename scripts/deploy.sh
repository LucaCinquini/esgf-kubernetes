#!/bin/sh
# Script to create all ESGF Kubernetes pods and services

kubectl create -f postgres-esgcet/deployment.yaml
kubectl create -f postgres-esgcet/service.yaml

sleep 5
kubectl create -f cog/deployment-postgres.yaml
kubectl create -f cog/service-postgres.yaml
kubectl create -f cog/deployment.yaml
kubectl create -f cog/service.yaml

sleep 5
kubectl create -f solr/deployment-master.yaml
kubectl create -f solr/service-master.yaml
kubectl create -f solr/deployment-slave.yaml
kubectl create -f solr/service-slave.yaml

sleep 5
kubectl create -f idp-node/deployment.yaml
kubectl create -f idp-node/service.yaml

sleep 5
kubectl create -f index-node/deployment.yaml
kubectl create -f index-node/service.yaml

sleep 5
#kubectl create -f tds/volumes.yaml
kubectl create -f tds/deployment.yaml
kubectl create -f tds/service.yaml

sleep 5
kubectl create -f orp/deployment.yaml
kubectl create -f orp/service.yaml

sleep 5
kubectl create -f auth/deployment-postgres.yaml
kubectl create -f auth/service-postgres.yaml
sleep 5
kubectl create -f auth/deployment.yaml
kubectl create -f auth/service.yaml

sleep 5
kubectl create -f slcs/deployment-postgres.yaml
kubectl create -f slcs/service-postgres.yaml
sleep 5
kubectl create -f slcs/deployment.yaml
kubectl create -f slcs/service.yaml

sleep 5

# minikube: expose stack via Ingress
kubectl create -f proxy/ingress.yaml

# GKE: expose stack via Service of type LoadBalancer tied to a static IP address
# kubectl create -f proxy/deployment.yaml
# kubectl create -f proxy/service.yaml
