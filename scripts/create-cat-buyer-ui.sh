#!/bin/bash

##################
# CaT UI App
##################
# Deployed via Travis build

#######################
# Bind to Services
#######################
cf bind-service $ENV_APP_NAME_UI $(expand_var $UPS_NAME)

##################
# Create Network Policy
# Allows public UI app to connect to private API service
##################
cf add-network-policy $ENV_APP_NAME_UI $ENV_APP_NAME_API --protocol tcp --port 8080

#######################
# Set ENV variables
#######################
cf set-env $ENV_APP_NAME_UI TENDERS_API_BASE_URL $(expand_var $TENDERS_API_BASE_URL)

#######################
# Restage and start
#######################
cf restage $ENV_APP_NAME_UI
