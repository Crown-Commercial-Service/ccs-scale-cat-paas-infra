#!/bin/bash

#######################
# CaT IP authentication app and router service
# See: 
# https://docs.cloud.service.gov.uk/deploying_services/route_services/#example-route-service-to-add-ip-address-authentication
#######################

ENV_APP_NAME_IP_ROUTER=$(expand_var $APP_NAME_IP_ROUTER)
ENV_UPS_NAME_ROUTE_SERVICE=$(expand_var $UPS_NAME_ROUTE_SERVICE)

# Push the IP Router app (nginx)
cf push -f ./ip-router-app/manifest.yml -p ./ip-router-app --var APP_NAME=$ENV_APP_NAME_IP_ROUTER \
    --var INSTANCES=$INSTANCES_IP_ROUTER --var MEMORY=$MEMORY_IP_ROUTER --no-start

# Create or update the route service
if cf service $ENV_UPS_NAME_ROUTE_SERVICE &> /dev/null; then
    cf uups $ENV_UPS_NAME_ROUTE_SERVICE -r "https://${ENV_APP_NAME_IP_ROUTER}.${REGION_DOMAIN}"
else
    cf cups $ENV_UPS_NAME_ROUTE_SERVICE -r "https://${ENV_APP_NAME_IP_ROUTER}.${REGION_DOMAIN}"
fi

cf set-env $ENV_APP_NAME_IP_ROUTER ALLOWED_IPS "${NGINX_CIDRS_ALLOWED_EXTERNAL}"
cf restage $ENV_APP_NAME_IP_ROUTER

# Bind the route service to the app(s)
# TODO: Replace HOSTNAME with that of the cat-buyer-ui once known and reinstate
# cf bind-route-service $REGION_DOMAIN --hostname "test-ip-router" $ENV_UPS_NAME_ROUTE_SERVICE
