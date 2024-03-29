#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../utils/uservices.src"
source "${DIR}/../utils/docker.src"

CONTAINER_PREFIX="poc_nginx"
CONTAINER1_NAME="${CONTAINER_PREFIX}_1"
FILE_NAME="index_$(date '+%Y%m%d').html"

CONTAINER_HTTP_PORT="80"
HOST_HTTP_PORT="8080"

function initialize() {
  print_info "Preparing poc environment..."
  setTerminalSignals
  cleanup
}

function handleTermSignal() {
  xtrace off
  print_warn "Handling termination signal..."
  cleanup
  exit 1
}

function cleanup {
  print_debug "Cleaning environment..."
  containers=($(docker::getAllContainerIdsByPrefix ${CONTAINER_PREFIX}))
  docker::removeContainers ${containers[*]}
}

function executeContainers {
  print_info "Execute container with HTTP server..."
  xtrace on
  docker run -d \
    --rm \
    --name ${CONTAINER1_NAME} \
    -p ${HOST_HTTP_PORT}:${CONTAINER_HTTP_PORT} \
    nginx

  xtrace off
}

function main {
  print_info "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  executeContainers
  print_info "Check containers status..."
  docker::showContainersByPrefix ${CONTAINER_PREFIX}

  docker::checkHttpServerAvailability ${CONTAINER1_NAME} ${CONTAINER_HTTP_PORT}
  isHttpServer1Available=$?

  if [ $isHttpServer1Available -ne 0 ]; then
    print_error "Poc completed with failure"
    exit 1
  fi

  print_info "Copy welcome file from Http server container to local filesystem..."
  docker::copyFiles ${CONTAINER1_NAME}:/usr/share/nginx/html/index.html /tmp/$FILE_NAME

  print_info "Modify file $FILE_NAME..."
  textToReplace="Hello ${USER^},<br\/> Welcome"
  xtrace on
  sed -i "s/Welcome/$textToReplace/g" /tmp/$FILE_NAME
  #cat /tmp/$FILE_NAME
  xtrace off
  checkInteractiveMode

  print_info "Copy new welcome file from local filesystem to Http server container..."
  docker::copyFiles /tmp/$FILE_NAME ${CONTAINER1_NAME}:/usr/share/nginx/html/index.html

  docker::checkHttpServerAvailability ${CONTAINER1_NAME} ${CONTAINER_HTTP_PORT}
  isHttpServer1Available=$?

  if [ $isHttpServer1Available -ne 0 ]; then
    print_error "Poc completed with failure"
    exit 1
  fi

  checkCleanupMode
  print_done "Poc completed successfully"
  exit 0
}

main $@
