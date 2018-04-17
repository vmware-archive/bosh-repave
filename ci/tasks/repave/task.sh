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

  jobIndexToCheck="1"
  if [ "${REPAVE_SINGLETON_JOBS,,}" == "true" ]; then
    jobIndexToCheck="0"
  fi

  dryRunStatement=""
  if [ "${PERFORM_DRY_RUN_ONLY,,}" == "true" ]; then
    dryRunStatement="--dry-run"
  fi

  # get list of vms
  if [ -z "$JOBS" ]
  then
    JOBS=$(bosh -d $DEPLOYMENT_NAME --json instances -i | jq --arg jobIndexToCheck "$jobIndexToCheck" -r '.Tables[].Rows[] | select(.index==$jobIndexToCheck) | .instance | split("/")[0]')
  else
    JOBS=$(echo $JOBS | sed "s/,/ /g")
  fi

  for job in $JOBS
  do
    echo "Recreating job [$job]"
    bosh -d $DEPLOYMENT_NAME -n recreate $dryRunStatement $job
  done

done
