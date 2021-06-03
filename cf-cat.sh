#!/bin/bash
#
# CCS Scale CaT - GPaaS Cloud Foundry provisioning control script
# Usage:
# [SKIP_UPS=true] cf-cat.sh -o <ccs-scale-cat> -e <sbx1|sbx2|sbx3|sbx-spark|dev|int> <apply|destroy> <svcs|apps|all>
#
# SKIP_UPS (Skip User-provided services) can be set to true on subsequent backing service updates to avoid having to
# re-enter all the values for each UPS
#
# e.g.
# cf-cat.sh -o ccs-scale-cat -e sbx3 apply all
# cf-cat.sh -o ccs-scale-cat -e sbx3 destroy apps
# SKIPUPS=true cf-cat.sh -o ccs-scale-cat -e sbx3 apply svcs
#

set -meo pipefail

usage() { echo "Usage: $0 [-o <ccs-scale-cat>] [-e <sbx1|sbx2|dev|int>] <apply|destroy> <svcs|apps|all>" 1>&2; exit 1; }

get_environment_property () {
  cat ${ENV_PROPS} | grep -w "$1" | cut -d'=' -f2
}

expand_var () {
  echo $(eval echo "$1")
}

while getopts ":o:e:" o; do
    case "${o}" in
        o)
            ORG=${OPTARG:='ccs-scale-cat'}
            ;;
        e)
            export ENV=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

# Check null/empty options and args
if [ -z "${ORG}" ] || [ -z "${ENV}" ] || [ -z "$1" ] || [ -z "$2" ]; then
    usage
fi

ACTION=$1
SCOPE=$2
ENV_PROPS="./config/${ENV}.properties"

if [[ ! -f $ENV_PROPS ]]; then
  echo "Environment (space) config file [$ENV_PROPS] not found"
  exit 1;
fi

if [[ $ACTION = "apply" ]]; then
  . ./scripts/apply.sh
elif [[ $ACTION = "destroy" ]]; then
  . ./scripts/destroy.sh
else
  echo "Unrecognised action [$ACTION]. Only 'apply or 'destroy' are valid."
  usage
fi
