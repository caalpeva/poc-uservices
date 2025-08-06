#!/bin/bash

DIR=$(dirname $(readlink -f $0))

PROJECT_NAME="poc-shopping"
DOMAIN_NAME="poc-shopping"

function main {
  docker run --network=host \
    --rm ubercadence/cli:master \
    --do $DOMAIN_NAME domain register -rd 1

  docker run --network=host \
    --rm ubercadence/cli:master \
    --do $DOMAIN_NAME domain describe
}

main $@
