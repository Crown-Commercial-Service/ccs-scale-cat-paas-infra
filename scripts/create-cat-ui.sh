#!/bin/bash

##################
# CaT UI App
##################

# Deployed via Travis build

#######################
# Bind to Services
#######################

cf bind-service $APP_NAME_UI $(expand_var $UPS_NAME)

##################
# Create Network Policy
# Allows public UI app to connect to private API service
##################

cf add-network-policy $APP_NAME_UI $APP_NAME_API --protocol tcp --port 8080

#######################
# Log drain to logit.io
#######################

cf bind-service $APP_NAME_UI $(expand_var $UPS_NAME_LOG_DRAIN_SERVICE)
