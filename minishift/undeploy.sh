#!/usr/bin/env bash

# User
USER=admin
PASSWORD=admin
PROJECT=fragalysis-cicd

set -e pipefail

# Pickup the OC command suite...
eval $(minishift oc-env)

oc login -u $USER -p $PASSWORD > /dev/null
oc project $PROJECT > /dev/null

echo
echo "- Undeploying Application..."

oc delete all,route --selector template=fs-web
oc delete all,secrets --selector template=fs-cartridge
oc delete all --selector template=fs-db
oc delete all --selector template=fs-graph

echo
echo "- Removing Secrets..."

oc delete secrets --selector template=fs-secrets

echo
echo "- Deleting Loaders..."

oc delete all --selector template=fs-web-media-loader

echo
echo "- Deleting PVCs..."

oc delete pvc --selector template=fs-cartridge-pvc
oc delete pvc --selector template=fs-db-pvc

echo
echo "- Deleting PVs..."

oc login -u system:admin > /dev/null
oc delete pv --selector template=fs-pv-minishift
