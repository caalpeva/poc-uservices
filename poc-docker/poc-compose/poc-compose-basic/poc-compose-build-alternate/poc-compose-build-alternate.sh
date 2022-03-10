#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../../../utils/microservices-utils.src"
source "${DIR}/../../../utils/docker-utils.src"
source "${DIR}/../../../utils/docker-compose.src"

CONTAINER_NAME="poc_alpine_build_alternate"

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
  docker_compose::up --build

  print_info "Check containers status..."
  docker_compose::ps

  print_info "Execute command in container"
  docker_utils::execContainer ${CONTAINER_NAME} "tree -L 1"
  if [ $? -ne 0 ]; then
    print_error "Poc completed with failure"
    exit 1
  fi

  checkCleanupMode
  print_done "Poc completed successfully "
  exit 0
}

main $@
