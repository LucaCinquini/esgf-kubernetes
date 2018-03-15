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

### Deployment

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

Test basic functionality of the ESGF services. In the URLs below, replace the node hostname with your specific value for $ESGF_HOSTNAME.

* CoG: https://esgf.192.168.64.12.xip.io/ . Login with:
  * openid: https://esgf.192.168.64.12.xip.io/esgf-idp/openid/rootAdmin
  * password from: cat $ESGF_CONFIG/secrets/rootadmin-password
  
* Solr: https://esgf.192.168.64.12.xip.io/solr/#/

* ESGF Search: https://esgf.192.168.64.12.xip.io/esg-search/search . Note: at this time, this URL os very slow...

* ESGF IdP: https://esgf.192.168.64.12.xip.io/esgf-idp/

* ESGF TDS: https://esgf.192.168.64.12.xip.io/thredds/

* ESGF ORP: https://esgf.192.168.64.12.xip.io/esg-orp/ . Login with:
  * openid: https://esgf.192.168.64.12.xip.io/esgf-idp/openid/rootAdmin
  * password from: cat $ESGF_CONFIG/secrets/rootadmin-password
  
* ESGF-AUTH: https://esgf.192.168.64.12.xip.io/esgf-auth/home/

* SLCS: https://esgf.192.168.64.12.xip.io/esgf-slcs/admin/login/ . Login with:
  * username: rootAdmin
  * password from: cat $ESGF_CONFIG/secrets/rootadmin-password

### Cleanup

To simply stop the Kubernetes cluster (all Pods will be restarted when the cluster is restarted):

```
minikube stop
```

To completely delete all ESGF Kubernetes objects, run the following script:

```
./scripts/cleanup.sh
```

and then stop minikube.

### Other Notes

* To connect to the postgres databse from inside its container:

  ```
  kubectl get pods
  kubectl exec -it <postgres pod id> -- /bin/bash
  psql -U dbsuper esgcet
  [no password necessary]
  ```
