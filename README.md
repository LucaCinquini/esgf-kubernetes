# esgf-kubernetes

This repository contains configuration files for deploying the ESGF/Docker software stack on a Kubernetes cluster.

## Quick Start

The following instructions describe how to deploy ESGF/Docker on a single-node minikube cluster,
for the specific case of a Mac OSX laptop.

### Pre-requisites

The following packages must be installed on your system:

* minikube
* kubectl

### Setup

Start minikube with enough memory:

```
minikube start --vm-driver=xhyve --memory=4096
```

0) enable Ingress controller

on minikube: minikube addons enable ingress

0) Def env variables

export ESGF_HOSTNAME="esgf.$(minikube ip).xip.io"
export ESGF_CONFIG=/Users/cinquini/data/ESGF_CONFIG_CEDA

NOTE: must use an IP that is resolvable inside each k8s pod, simply mapping the minikube IP to a chosen hostname won't work for OpenID authentication

1) Create site configuration, certificates with esgf-setup container

cd ~/eclipse-workspace/esgf-docker-ceda
docker-compose run esgf-setup generate-secrets
docker-compose run esgf-setup generate-test-certificates
docker-compose run esgf-setup create-trust-bundle


2) Run script to create k8s configmaps and secrets

cd ~/eclipse-workspace/esgf-kubernetes
./scripts/setup.sh 


3) run script to start all k8s pods and services:

./scripts/deploy.sh

4) testing

o CoG: https://esgf.192.168.64.12.xip.io/
- login with https://esgf.192.168.64.12.xip.io/esgf-idp/openid/rootAdmin
  password from: $ESGF_CONFIG/secrets/rootadmin-password
  
o Solr: https://esgf.192.168.64.12.xip.io/solr/#/

o ESGF Search: https://esgf.192.168.64.12.xip.io/esg-search/search

o IdP: https://esgf.192.168.64.12.xip.io/esgf-idp/

o TDS: https://esgf.192.168.64.12.xip.io/thredds/

o ORP: https://esgf.192.168.64.12.xip.io/esg-orp/
- login with https://esgf.192.168.64.12.xip.io/esgf-idp/openid/rootAdmin
  password from: $ESGF_CONFIG/secrets/rootadmin-password
  
o ESGF-AUTH: https://esgf.192.168.64.12.xip.io/esgf-auth/home/

o SLCS: https://esgf.192.168.64.12.xip.io/esgf-slcs/admin/login/



o SLCS

5) clean up:

kubectl delete deployment,svc,statefulset -l stack=esgf

kubectl delete secrets esgf-auth-secrets esgf-cog-secrets esgf-hostcert esgf-postgres-secrets esgf-slcs-ca esgf-tds-secrets esgf-slcs-secrets

kubectl delete configmap esgf-config esgf-trust-bundle

============


# Postgres

cd postgres
kubectl create -f secret.yaml 
kubectl create -f deployment.yaml
kubectl create -f service.yaml

to connect to the postgres from inside its container:

kubectl get pods
kubectl exec -it postgres-deployment-f9d9848f5-hqbp2 -- /bin/bash
psql -U dbsuper esgcet
[no password necessary]


# Configmaps and Secrets
kubectl create secret tls esgf-hostcert --cert=$ESGF_CONFIG/certificates/hostcert/hostcert.crt  --key=$ESGF_CONFIG/certificates/hostcert/hostcert.key
kubectl create configmap esgf-trust-bundle --from-file=$ESGF_CONFIG/certificates/esg-trust-bundle.pem

kubectl create configmap esgf-config --from-literal=esgf-hostname=$ESGF_HOSTNAME --from-literal=root-admin-email=CoG@$ESGF_HOSTNAME --from-literal=root-admin-openid=https://$ESGF_HOSTNAME/esgf-idp/openid/rootAdmin --from-literal=slcs-url=https://$ESGF_HOSTNAME/esgf-slcs

kubectl create secret tls esgf-slcs-ca --cert=$ESGF_CONFIG/certificates/slcsca/ca.crt  --key=$ESGF_CONFIG/certificates/slcsca/ca.key

# new
kubectl create secret generic esgf-postgres-secrets --from-file=$ESGF_CONFIG/secrets/database-password --from-file=$ESGF_CONFIG/secrets/database-publisher-password --from-file=$ESGF_CONFIG/secrets/rootadmin-password

kubectl create secret generic esgf-cog-secrets --from-file=$ESGF_CONFIG/secrets/rootadmin-password --from-file=$ESGF_CONFIG/secrets/cog-secret-key

kubectl create secret generic esgf-auth-secrets --from-file=$ESGF_CONFIG/secrets/auth-database-password --from-file=$ESGF_CONFIG/secrets/auth-secret-key --from-file=$ESGF_CONFIG/secrets/shared-cookie-secret-key

kubectl create secret generic esgf-slcs-secrets --from-file=$ESGF_CONFIG/secrets/slcs-database-password --from-file=$ESGF_CONFIG/secrets/slcs-secret-key

kubectl create secret generic esgf-tds-secrets --from-file=$ESGF_CONFIG/secrets/shared-cookie-secret-key --from-file=$ESGF_CONFIG/secrets/rootadmin-password

# Zookeeper
kubectl create -f deployment.yaml
kubectl create -f service.yaml


# Solr
kubectl create -f deployment.yaml
kubectl create -f service.yaml

curl -v http://localhost:8983/solr/#/datasets

# Index Node
kubectl create -f deployment.yaml
kubectl create -f service.yaml

from within container:
curl -v 'http://localhost:8080/esg-search/search'

from outside:
http://192.168.64.12:32374/esg-search/search

BUT REALLY SLOW!!!! WHILE SOLR IS FAST....

# IdP Node

kubectl create -f deployment.yaml
kubectl create -f service.yaml

from within the container:
curl -v http://localhost:8080/esgf-idp/

from outside:
curl -v 'http://192.168.64.12:31137/esgf-idp/'

# CoG
kubectl create -f deployment.yaml
kubectl create -f service.yaml

test:

http://my-node.esgf.org:30906/projects/testproject/
AFTER MAPPING MINIKUBE IP: 192.168.64.12 to 'my-node.esgf.org'

# TDS

kubectl create -f secret.yaml 
kubectl create -f deployment.yaml
kubectl create -f service.yaml

test: http://my-node.esgf.org:31463/thredds/catalog/esgcet/catalog.html
AFTER MAPPING MINIKUBE IP: 192.168.64.12 to 'my-node.esgf.org'

# ORP
kubectl create -f deployment.yaml
kubectl create -f service.yaml

# SLCS

kubectl create -f secret.yaml
kubectl create -f deployment-postgres.yaml
kubectl create -f service-postgres.yaml 
kubectl create -f deployment.yaml 
kubectl create -f service.yaml

test URL: http://my-node.esgf.org:30155/esgf-slcs/admin/login/?next=/esgf-slcs/admin/
CANNOT AUTHENTICATE TO SLCS

# AUTH

kubectl create -f secret.yaml 
kubectl create -f deployment-postgres.yaml
kubectl create -f service-postgres.yaml
kubectl create -f deployment.yaml
kubectl create -f service.yaml

URL: http://my-node.esgf.org:31822/esgf-auth/home/

# PROXY

kubectl create -f deployment.yaml 
kubectl create -f service.yaml

https://my-node.esgf.org:30494/projects/testproject/
- can login with login2/

https://my-node.esgf.org:30494/solr/#/

https://my-node.esgf.org:30494/esg-search/search (SLOW!!!)

https://my-node.esgf.org:30494/esgf-idp/

https://my-node.esgf.org:30494/esg-orp/home.htm

https://my-node.esgf.org:30494/thredds/catalog/catalog.html

https://my-node.esgf.org:30494/esgf-auth/home/

https://my-node.esgf.org:30494/esgf-slcs/admin/login/?next=/esgf-slcs/admin/
