#!/bin/bash

##################
# Postgres Service
##################
cf delete-service -f $(expand_var ${SERVICE_NAME_PG})

#############
# User-Provided Services
#############
cf delete-service -f $(expand_var $UPS_NAME)

# Uncomment / reinstate as required for each binding to the router service
# cf unbind-service test-ip-router $(expand_var $UPS_NAME_ROUTE_SERVICE)
cf delete-service -f $(expand_var $UPS_NAME_ROUTE_SERVICE)

#############
# Router service app
#############
cf delete -f $(expand_var $APP_NAME_IP_ROUTER)


