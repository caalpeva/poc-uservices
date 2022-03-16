#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../utils/microservices-utils.src"
source "${DIR}/../utils/docker.src"

CONTAINER_PREFIX="poc_alpine"
CONTAINER1_NAME="${CONTAINER_PREFIX}_1"

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

function executeContainer {
  print_info "Run container with simple command..."
  xtrace on
  docker run --name ${CONTAINER1_NAME} \
    alpine cat /etc/os-release

  xtrace off
}

function main {
  print_info "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  executeContainer
  print_info "Check containers status..."
  docker::showContainersByPrefix ${CONTAINER_PREFIX}

  print_info "Show logs..."
  docker::showLogs ${CONTAINER1_NAME}

  checkCleanupMode
  print_done "Poc completed successfully"
  exit 0
}

main $@
