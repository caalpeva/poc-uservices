#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../utils/microservices-utils.src"
source "${DIR}/../utils/docker.src"

CONTAINER_PREFIX="poc_ubuntu_top"
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

function executeContainers {
  print_info "Run containers..."  
  xtrace on
  docker run -dit \
    --name ${CONTAINER1_NAME} \
    ubuntu /usr/bin/top -b

  xtrace off
}

function main {
  print_info "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  executeContainers
  print_info "Check containers status..."
  docker::showContainersByPrefix ${CONTAINER_PREFIX}

  print_info "Attach container..."
  print_info "-Press CTRL+C to interrupt the program the and stop the container"
  print_info "-Press CTRL+P+Q to keep the container in background"
  docker::attachContainer ${CONTAINER1_NAME}

  print_info "Check containers status again..."
  docker::showContainersByPrefix ${CONTAINER_PREFIX}

  checkCleanupMode
  print_done "Poc completed successfully "
  exit 0
}

main $@
