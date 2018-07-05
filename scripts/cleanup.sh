#!/bin/sh
# Script to delete all ESGF Kubernetes objects

kubectl delete deployment,svc,statefulset,ingress -l stack=esgf
kubectl delete secrets esgf-auth-secrets esgf-cog-secrets esgf-hostcert esgf-postgres-esgcet-secrets esgf-slcs-ca esgf-tds-secrets esgf-slcs-secrets esgf-publisher-secrets
kubectl delete configmap esgf-config esgf-trust-bundle
kubectl delete pvc -l stack=esgf