#!/bin/bash

#############
# Log Drain User-Provided Service
# Drains logs to logit.io
#############
create_update_log_drain_ups () {

  APP_NAME=$1
  UPS_NAME=$2

  # TODO: Improve the sed command to remove need to prefix with additional '{' char
  VCAP_SERVICES="{$(cf env $APP_NAME | sed -n '/^VCAP_SERVICES:/,/^$/{//!p;}')"

  LOGIT_HOSTNAME=$(echo $VCAP_SERVICES | jq -r '."user-provided"[] | select(.name == env.ENV_UPS_NAME).credentials."logit-hostname"')
  LOGIT_PORT=$(echo $VCAP_SERVICES | jq -r '."user-provided"[] | select(.name == env.ENV_UPS_NAME).credentials."logit-port"')

  if cf service $UPS_NAME &> /dev/null; then
	cf uups $UPS_NAME -l syslog-tls://$LOGIT_HOSTNAME:$LOGIT_PORT
  else
	cf cups $UPS_NAME -l syslog-tls://$LOGIT_HOSTNAME:$LOGIT_PORT
  fi	
  
}


ENV_LOG_DRAIN_UPS_NAME=$(expand_var $UPS_NAME_LOG_DRAIN_SERVICE)
create_update_log_drain_ups "$ENV_APP_NAME_API" "$ENV_LOG_DRAIN_UPS_NAME"
  
cf bind-service $ENV_APP_NAME_API $(expand_var $UPS_NAME_LOG_DRAIN_SERVICE)
cf bind-service $ENV_APP_NAME_UI $(expand_var $UPS_NAME_LOG_DRAIN_SERVICE)
