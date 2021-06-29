#!/bin/bash
set +e +o pipefail

ENV_SERVICE_NAME_PG=$(expand_var ${SERVICE_NAME_PG})
ENV_APP_NAME_API=$(expand_var ${APP_NAME_API})
ENV_UPS_NAME=$(expand_var $UPS_NAME)
ENV_UPS_NAME_ROUTE_SERVICE=$(expand_var $UPS_NAME_ROUTE_SERVICE)

##################
# Postgres Service
##################
cf delete-service-key -f $ENV_SERVICE_NAME_PG $(expand_var ${SERVICE_KEY_PG})
cf unbind-service $(expand_var ${APP_NAME_API}) $ENV_SERVICE_NAME_PG
cf delete-service -f $ENV_SERVICE_NAME_PG

while cf service "${ENV_SERVICE_NAME_PG}" | grep -q "delete in progress"; do
    sleep 10
    echo "Waiting for ${ENV_SERVICE_NAME_PG} to finish deleting..."
done

#############
# User-Provided Services
#############
cf unbind-service $ENV_APP_NAME_API $ENV_UPS_NAME
cf delete-service -f $ENV_UPS_NAME

# Uncomment / reinstate as required for each binding to the router service
cf unbind-route-service -f $REGION_DOMAIN --hostname "test-ip-router" $ENV_UPS_NAME_ROUTE_SERVICE
cf delete-service -f $ENV_UPS_NAME_ROUTE_SERVICE

#############
# Router service app
#############
cf delete -f $(expand_var $APP_NAME_IP_ROUTER)


