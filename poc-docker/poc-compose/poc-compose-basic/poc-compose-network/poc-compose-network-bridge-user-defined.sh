#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../../../utils/microservices-utils.src"
source "${DIR}/../../../utils/docker-utils.src"
source "${DIR}/../../../utils/docker-compose.src"

CONTAINER_PREFIX="poc_alpine"
CONTAINER1_NAME="${CONTAINER_PREFIX}_1"
CONTAINER2_NAME="${CONTAINER_PREFIX}_2"

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

  print_box "****************" \
    "" \
    " - " \
    " - " \
    " - "
  checkInteractiveMode

  print_info "Execute docker-compose"
  docker_compose::up

  print_info "Check containers status..."
  docker_compose::ps ${CONTAINER_PREFIX}

  print_info "Check connection from ${CONTAINER1_NAME} to ${CONTAINER2_NAME} by name"
  docker_utils::execContainerPingAsRoot ${CONTAINER1_NAME} ${CONTAINER2_NAME}
  if [ $? -ne 0 ]; then
    print_error "Poc completed with failure"
    exit 1
  fi

  checkInteractiveMode
  print_info "Check /etc/hosts file from ${CONTAINER1_NAME}"
  print_debug "No line added in /etc/hosts because network uses DNS and containers can resolve each other by name "
  docker_utils::execContainer ${CONTAINER1_NAME} "cat /etc/hosts"

  checkCleanupMode
  print_done "Poc completed successfully "
  exit 0
}

main $@
