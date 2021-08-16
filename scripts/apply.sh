#!/bin/bash
#
# Applies (creates / updates) the CF infra
#

echo "ORG=${ORG}"
echo "ENV=${ENV}"
echo "ACTION=${ACTION}"
echo "SCOPE=${SCOPE}"

# Load global defaults and environment specific config
. ./config/global.properties
. ./config/$ENV.properties

cf target -o $ORG -s $SPACE

# Create / update backing services
if [[ $SCOPE =~ svcs|all ]]; then
  . ./scripts/create-services.sh
  . ./scripts/create-ip-router-service.sh
fi

# Create / update applications
if [[ $SCOPE =~ app|all ]]; then
  export CF_DOCKER_PASSWORD=$AWS_ECR_REPO_SECRET_ACCESS_KEY

  # CaT API & UI
  APP_NAME_API=$(expand_var $APP_NAME_API)
  APP_NAME_UI=$(expand_var $APP_NAME_UI)
  . ./scripts/create-cat-api.sh
  . ./scripts/create-cat-ui.sh
fi
