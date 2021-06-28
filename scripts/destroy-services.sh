#!/bin/bash

##################
# Postgres Service
##################
cf delete-service -f $(expand_var ${SERVICE_NAME_PG})

#############
# User-Provided Services
#############
cf delete-service -f $(expand_var $UPS_NAME)
cf delete-service -f $(expand_var $UPS_NAME_ROUTE_SERVICE)

#############
# Router service app
#############
cf delete -f $(expand_var $APP_NAME_IP_ROUTER)


