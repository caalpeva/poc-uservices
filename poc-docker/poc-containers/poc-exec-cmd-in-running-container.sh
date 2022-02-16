#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../utils/microservices-utils.src"
source "${DIR}/../utils/docker-utils.src"

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
  containers=($(docker_utils::getAllContainerIdsByPrefix ${CONTAINER_PREFIX}))
  docker_utils::removeContainers ${containers[*]}
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
  docker_utils::showContainersByPrefix ${CONTAINER_PREFIX}

  print_info "Execute command in the running container..."
  docker_utils::execContainer ${CONTAINER1_NAME} "ps aux"

  print_info "Check containers status again..."
  docker_utils::showContainersByPrefix ${CONTAINER_PREFIX}

  print_info "Run command in the same running container with tty..."
  print_debug "Use the shell for example to execute:\n\tps aux"
  print_info "-Type exit or press CTRL+D to exit and stop the container"
  print_info "-Press CTRL+P+Q to keep the container in background"
  docker_utils::execContainerWithTty ${CONTAINER1_NAME} "/bin/sh"

  print_info "Check containers status again..."
  docker_utils::showContainersByPrefix ${CONTAINER_PREFIX}

  checkCleanupMode
  print_done "Poc completed successfully "
  exit 0
}

main $@