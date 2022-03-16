#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../utils/microservices-utils.src"
source "${DIR}/../utils/docker.src"

CONTAINER_PREFIX="poc_httpd"
CONTAINER1_NAME="${CONTAINER_PREFIX}_1"
CONTAINER2_NAME="${CONTAINER_PREFIX}_2"

CONTAINER_HTTP_PORT="80"
HOST_HTTP_PORT="81"

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
  print_info "Execute containers with HTTP servers ..."
  xtrace on
  docker run -d \
    --rm \
    --name ${CONTAINER1_NAME} \
    -p ${HOST_HTTP_PORT}:${CONTAINER_HTTP_PORT} \
    httpd

  docker run -d \
    --rm \
    --name ${CONTAINER2_NAME} \
    -P \
    httpd

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

  docker::checkHttpServerAvailability ${CONTAINER2_NAME} ${CONTAINER_HTTP_PORT}
  isHttpServer2Available=$?

  if [ $isHttpServer1Available -ne 0 -o $isHttpServer2Available -ne 0 ]; then
    print_error "Poc completed with failure"
    exit 1
  fi

  checkCleanupMode
  print_done "Poc completed successfully"
  exit 0
}

main $@
