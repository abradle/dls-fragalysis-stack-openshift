#!/usr/bin/env bash

# Assumes the Application's Persistent Volumes are available
# and a number of other container images have been deployed
# (namely the informatics matters images for the data loaders
# and forked repos).

# Service account
SA=diamond
# User
USER=admin
PASSWORD=admin
PROJECT=fragalysis-cicd

# Pickup the OC command suite...
eval $(minishift oc-env)

# As system admin...
oc login -u system:admin > /dev/null

# Allow containers to run as root...
oc adm policy add-scc-to-user anyuid -z default > /dev/null

# Create the project?
oc get projects/$PROJECT > /dev/null 2> /dev/null
if [ $? -ne 0 ]
then
    echo
    echo "+ Creating Fragalysis Project..."
    oc login -u $USER -p $PASSWORD > /dev/null
    oc new-project $PROJECT --display-name='Fragalysis Stack' > /dev/null
fi

oc get sa/$SA > /dev/null 2> /dev/null
if [ $? -ne 0 ]
then
    # Create Diamond-specific service account in the Fragalysys Stack project.
    # To avoid privilege escalation in the default account.
    # An experiment with Service Accounts (unused ATM)
    echo
    echo "+ Creating Service Account..."
    oc login -u system:admin > /dev/null
    oc project $PROJECT > /dev/null
    oc create sa $SA 2> /dev/null
    # provide cluster-admin role (ability to launch containers)
    oc adm policy add-cluster-role-to-user cluster-admin -z $SA
    # Allow (legacy) containers to run as root...
    oc adm policy add-scc-to-user anyuid -z $SA
fi

set -e pipefail

echo
echo "+ Creating PVs..."

oc login -u system:admin > /dev/null
oc process -f fs-pv-minishift.yaml | oc create -f -

echo
echo "+ Creating PVCs..."

oc login -u $USER -p $PASSWORD > /dev/null
oc project $PROJECT > /dev/null

oc process -f ../templates/fs-db-pvc.yaml | oc create -f -
oc process -f ../templates/fs-cartridge-pvc.yaml | oc create -f -

echo
echo "+ Creating Secrets..."

oc process -f ../templates/fs-secrets.yaml | oc create -f -

echo
echo "+ Deploying Application..."

oc process -f ../templates/fs-graph.yaml | oc create -f -
oc process -f ../templates/fs-db.yaml | oc create -f -
oc process -f ../templates/fs-cartridge.yaml | oc create -f -
oc process -f ../templates/fs-web.yaml | oc create -f -
