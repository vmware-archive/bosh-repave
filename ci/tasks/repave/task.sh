#!/bin/bash -eu

source ./bosh-repave-repo/ci/scripts/export-director-metadata

echo "Logging in to bosh $BOSH_ADDRESS"
bosh alias-env bosh -e "${BOSH_ADDRESS}" --ca-cert "${BOSH_CA_CERT_PATH}"

export BOSH_ENVIRONMENT=bosh

om curl -p /api/v0/deployed/products > deployed_products.json

# loop through deployments
for deployment in $(echo $DEPLOYMENTS | sed "s/,/ /g")
do
  DEPLOYMENT_NAME=$(jq --arg deployment "$deployment" -r '.[] | select( .type | contains($deployment)) | .guid' "deployed_products.json")

  # get list of vms
  JOBS=$(bosh -d $DEPLOYMENT_NAME --json instances -i | jq -r '.Tables[].Rows[] | select(.index=="1") | .instance | split("/")[0]')

  for job in $JOBS
  do
    echo "Recreating job [$job]"
    bosh -d $DEPLOYMENT_NAME -n recreate $job
  done

done
