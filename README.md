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
kubectl create configmap trust-bundle-config --from-file=$ESGF_CONFIG/certificates/esg-trust-bundle.pem
