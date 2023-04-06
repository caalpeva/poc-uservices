#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../../../utils/uservices.src"
source "${DIR}/../../../utils/docker.src"
source "${DIR}/../../../utils/docker-compose.src"

CONTAINER_NAME="poc-centos"
CONTAINER_HTTP_PORT="8080"

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
  docker_compose::down
}

function main {
  print_info "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  print_info "Execute docker-compose"
  docker_compose::up

  print_info "Check containers status..."
  docker_compose::ps

  docker::checkHttpServerAvailability ${CONTAINER_NAME} ${CONTAINER_HTTP_PORT}
  if [ $? -ne 0 ]; then
    print_error "Poc completed with failure"
    exit 1
  fi

  checkCleanupMode
  print_done "Poc completed successfully "
  exit 0
}

main $@
