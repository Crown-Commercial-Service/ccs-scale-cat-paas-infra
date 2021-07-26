#!/bin/bash

#######################
# CaT API - TODO: Rely on deployment via travis only / in certain envs?
#######################
  # cf push -k $DISK_API -m $MEMORY_API -i $INSTANCES_API $APP_NAME \
  #   --docker-image $DOCKER_IMAGE_SPREE --docker-username $AWS_ECR_REPO_ACCESS_KEY_ID \
  #   -c "bundle exec sidekiq" --no-start --no-route -u process

  # Map an internal route to CaT API backend for UI
  # cf map-route $APP_NAME apps.internal --hostname $APP_NAME

#######################
# Bind to Services
#######################
cf bind-service $APP_NAME $(expand_var $SERVICE_NAME_PG)

# UPS
cf bind-service $APP_NAME $(expand_var $UPS_NAME)

##################################
# Set Environment Variables in App
##################################

# TODO: Improve the sed command to remove need to prefix with additional '{' char
VCAP_SERVICES="{$(cf env $APP_NAME | sed -n '/^VCAP_SERVICES:/,/^$/{//!p;}')"

echo "${VCAP_SERVICES}"
echo "${ENV}"
echo "${APP_NAME}"
export ENV_UPS_NAME=$(expand_var $UPS_NAME)

# CaT API
cf set-env $APP_NAME AGREEMENTS_SERVICE_API_KEY $(echo $VCAP_SERVICES | jq -r '."user-provided"[] | select(.name == env.ENV_UPS_NAME).credentials."agreements-svc-api-key"')
cf set-env $APP_NAME AGREEMENTS_SERVICE_URL $(echo $VCAP_SERVICES | jq -r '."user-provided"[] | select(.name == env.ENV_UPS_NAME).credentials."agreements-svc-url"')
cf set-env $APP_NAME "spring.security.oauth2.client.registration.jaggaer.client-id" $(echo $VCAP_SERVICES | jq -r '."user-provided"[] | select(.name == env.ENV_UPS_NAME).credentials."jaggaer-client-id"')
cf set-env $APP_NAME "spring.security.oauth2.client.registration.jaggaer.client-secret" $(echo $VCAP_SERVICES | jq -r '."user-provided"[] | select(.name == env.ENV_UPS_NAME).credentials."jaggaer-client-secret"')
cf set-env $APP_NAME "spring.security.oauth2.resourceserver.jwt.jwk-set-uri" $(echo $VCAP_SERVICES | jq -r '."user-provided"[] | select(.name == env.ENV_UPS_NAME).credentials."auth-server-jwk-set-uri"')

# Static / miscellaneous
#cf set-env $APP_NAME APP_DOMAIN "$APP_NAME.london.cloudapps.digital"

#######################
# Log drain to logit.io
#######################
LOGIT_HOSTNAME=$(echo $VCAP_SERVICES | jq -r '."user-provided"[] | select(.name == env.ENV_UPS_NAME).credentials."logit-hostname"')
LOGIT_PORT=$(echo $VCAP_SERVICES | jq -r '."user-provided"[] | select(.name == env.ENV_UPS_NAME).credentials."logit-port"')
cf cups logit-ssl-drain -l syslog-tls://$LOGIT_HOSTNAME:$LOGIT_PORT
cf bind-service $APP_NAME logit-ssl-drain

#######################
# Restage and start
#######################
cf restage $APP_NAME
