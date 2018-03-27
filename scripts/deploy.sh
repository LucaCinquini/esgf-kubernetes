#!/bin/sh
# Script to create all Kubernetes deployments, services, statefulsets, ingress

kubectl create -f postgres/deployment.yaml
kubectl create -f postgres/service.yaml

#sleep 5
#kubectl create -f zookeeper/statefulset.yaml
#kubectl create -f zookeeper/service.yaml

#sleep 5
#kubectl create -f cog/deployment.yaml
#kubectl create -f cog/service.yaml

sleep 5
#kubectl create -f solr/deployment.yaml
kubectl create -f solr/deployment-classic.yaml
kubectl create -f solr/service.yaml

sleep 5
kubectl create -f idp-node/deployment.yaml
kubectl create -f idp-node/service.yaml

sleep 5
kubectl create -f index-node/deployment.yaml
kubectl create -f index-node/service.yaml

sleep 5
kubectl create -f tds/deployment.yaml
kubectl create -f tds/service.yaml

sleep 5
kubectl create -f orp/deployment.yaml
kubectl create -f orp/service.yaml

#sleep 5
#kubectl create -f auth/deployment-postgres.yaml
#kubectl create -f auth/service-postgres.yaml
#sleep 5
#kubectl create -f auth/deployment.yaml
#kubectl create -f auth/service.yaml

sleep 5
kubectl create -f slcs/deployment-postgres.yaml
kubectl create -f slcs/service-postgres.yaml
sleep 5
kubectl create -f slcs/deployment.yaml
kubectl create -f slcs/service.yaml

sleep 5
kubectl create -f proxy/ingress.yaml
