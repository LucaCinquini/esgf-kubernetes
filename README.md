# esgf-kubernetes

This repository contains configuration files for deploying the ESGF/Docker software stack on a Kubernetes cluster.

## Quick Start

The following instructions describe how to deploy ESGF/Docker on a single-node minikube cluster,
for the specific case of a Mac OSX laptop.

### Pre-requisites

The following packages must be installed on your system:

* kubectl
* minikube
* xhyve VM driver

### Setup

Start minikube with enough memory:

```
minikube start --vm-driver=xhyve --memory=4096
```

Enable the Kubernetes Ingress controller:

```
minikube addons enable ingress
```

Define environment variables for the node hostname, and an empty directory that will contain the node specific configuration and secrets:

```
export ESGF_HOSTNAME="esgf.$(minikube ip).xip.io"
export ESGF_CONFIG=/Users/cinquini/data/ESGF_CONFIG_CEDA
```

Note: for OpenID authentication to work, the node hostname must be resolvable inside each Kubernetes Pod. Simply choosing a hostname and mapping it to the minikube node IP in `/etc/hosts` won't work...

Create the site configuration and certificates using the helper container that is part of the `esgf-docker` distribution. The resulting files
(passwords and certificates) will be located under $ESGF_CONFIG:

```
cd <any directory>
git clone https://github.com/cedadev/esgf-helm.git
cd esgf-helm
docker-compose run esgf-setup generate-secrets
docker-compose run esgf-setup generate-test-certificates
docker-compose run esgf-setup create-trust-bundle
```

### Deploy the ESGF stack

Run the following script to create Kubernetes ConfigMap and Secret objects that contain the certificates and passwords from the $ESGF_CONFIG directory:

```
cd <any directory>
git clone https://github.com/LucaCinquini/esgf-kubernetes.git
cd esgf-kubernetes
./scripts/setup.sh 
```

Run the follwing script to create Kubernetes Deployment and Service objects. The created Pods will host the ESGF/Docker containers.

```
./scripts/deploy.sh
```

Wait untill all Pods are running in a stable state:

```
kubectl get pods -l stack=esgf
```

## Testing

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
