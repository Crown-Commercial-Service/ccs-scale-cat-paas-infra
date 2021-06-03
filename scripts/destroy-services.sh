#!/bin/bash

##################
# Postgres Service
##################
cf delete-service -f $(expand_var ${SERVICE_NAME_PG})

#############
# User-Provided Services
#############
cf delete-service -f $(expand_var $UPS_NAME)
