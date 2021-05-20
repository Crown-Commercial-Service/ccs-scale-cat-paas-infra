#!/bin/bash
#
# Destroys the CF infra
#

echo "ORG=${ORG}"
echo "ENV=${ENV}"
echo "ACTION=${ACTION}"
echo "SCOPE=${SCOPE}"

# Load global defaults and environment specific config
. ./config/global.properties
. ./config/$ENV.properties

cf target -o $ORG -s $SPACE

# Destroy applications
if [[ $SCOPE =~ app|all ]]; then
  . ./scripts/destroy-apps.sh
fi

# Destroy backing services
if [[ $SCOPE =~ svcs|all ]]; then
  . ./scripts/destroy-services.sh
fi
