#!/bin/bash -eu

# om-linux --request-timeout 7200 export-installation --output-file om-installation/installation.zip

source ./bosh-repave-repo/ci/scripts/export-director-metadata

echo "Logging in to bosh $BOSH_ADDRESS"
bosh alias-env bosh -e "${BOSH_ADDRESS}" --ca-cert "${BOSH_CA_CERT_PATH}"

export BOSH_ENVIRONMENT=bosh

bosh deployments

# iterate through white-listed deployments

  # om-linux curl -p /api/v0/deployed/products > deployed_products.json


  # run bosh recreate all for the deployment

  # ERT_DEPLOYMENT_NAME=$(jq -r '.[] | select( .type | contains("cf")) | .guid' "deployed_products.json")
