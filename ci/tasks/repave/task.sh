#!/bin/bash -eu

# om-linux --request-timeout 7200 export-installation --output-file om-installation/installation.zip

source ./bosh-repave-repo/ci/scripts/export-director-metadata

echo "Logging in to bosh $BOSH_ADDRESS"
bosh alias-env bosh -e "${BOSH_ADDRESS}" --ca-cert "${BOSH_CA_CERT_PATH}"

export BOSH_ENVIRONMENT=bosh

om curl -p /api/v0/deployed/products > deployed_products.json

# loop through deployments
echo "Iterating through list of deployments"
for deployment in $(echo $DEPLOYMENTS | sed "s/,/ /g")
do
  DEPLOYMENT_NAME=$(jq -r '.[] | select( .type | contains("${deployment}")) | .guid' "deployed_products.json")
  echo $DEPLOYMENT_NAME
done



# parse deployments

# iterate through white-listed deployments



  # run bosh recreate all for the deployment
