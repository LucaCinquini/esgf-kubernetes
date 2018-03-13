# Postgres

cd postgres
kubectl create -f secret.yaml 
kubectl create -f deployment.yaml

to connect to the postgres from inside its container:

kubectl get pods
kubectl exec -it postgres-deployment-f9d9848f5-hqbp2 -- /bin/bash
psql -U dbsuper esgcet
[no password necessary]


# Certificates
kubectl create secret tls hostcert-secret --cert=$ESGF_CONFIG/certificates/hostcert/hostcert.crt  --key=$ESGF_CONFIG/certificates/hostcert/hostcert.key
kubectl create configmap esgf-trust-bundle --from-file=$ESGF_CONFIG/certificates/esg-trust-bundle.pem

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