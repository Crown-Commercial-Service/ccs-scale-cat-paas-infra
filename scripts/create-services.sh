#!/bin/bash

##################
# Postgres Service
##################
ENV_SERVICE_NAME_PG=$(expand_var ${SERVICE_NAME_PG})
cf create-service postgres $SERVICE_PLAN_PG $ENV_SERVICE_NAME_PG

while cf service "${ENV_SERVICE_NAME_PG}" | grep -q "in progress"; do
    sleep 20
    echo "Waiting for ${ENV_SERVICE_NAME_PG} to finish provisioning..."
done

cf create-service-key $(expand_var ${SERVICE_NAME_PG}) $(expand_var ${SERVICE_KEY_PG})

#############
# User-Provided Services
# Encapsulates external service details including credentials. Prompts for user input.
#############
create_update_ups () {
  UPS_NAME=$1
  UPS_LABEL=$2
  UPS_PROPS=$3

  # If the service already exists, update it otherwise create it
  if cf service $UPS_NAME &> /dev/null; then
    # TODO: Create github issue - input prompt does not work
    # https://github.com/cloudfoundry/cli/issues
    echo "Update $UPS_LABEL service details as prompted:"
    # cf uups $UPS_NAME -p "$UPS_PROPS"
  else
    echo "Enter $UPS_LABEL service details as prompted:"
    cf cups $UPS_NAME -p "$UPS_PROPS"
  fi
}

# Set env/shell variable SKIP_UPS=true to avoid re-running these commands
if [[ "$SKIP_UPS" != true ]]; then
  ENV_UPS_NAME=$(expand_var $UPS_NAME)
  ENV_UPS_LABEL="${ENV} CaT UPS"
  UPS_PROPS="jaggaer-client-id, jaggaer-client-secret, auth-server-jwk-set-uri, agreements-svc-api-key, agreements-svc-url"
  create_update_ups "$ENV_UPS_NAME" "$ENV_UPS_LABEL" "$UPS_PROPS"
fi
