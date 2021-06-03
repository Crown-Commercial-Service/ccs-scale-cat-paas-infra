#!/bin/bash

###############
# Delete network policies
###############
cf remove-network-policy $(expand_var $APP_NAME_UI) $(expand_var $APP_NAME_API) -s $SPACE -o $ORG --protocol tcp --port 8080 || true

#######################
# CaT API Service
#######################
cf delete -f $(expand_var $APP_NAME_UI)
cf delete -f $(expand_var $APP_NAME_API)
