#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../../../dependencies/downloads/poc-bash-master/includes/progress-bar-utils.src"
source "${DIR}/../../../../utils/uservices.src"
source "${DIR}/../../../utils/docker.src"
source "${DIR}/../../../utils/docker-compose.src"

PROJECT_NAME="poc_portainer"

CONTAINER_PREFIX="poc_portainer"
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
  docker_compose::downWithProjectName $PROJECT_NAME -v
}

function main {
  print_info "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  print_box "PORTAINER" \
    "" \
    " - Portainer is a web tool to manage docker containers locally or remotely."
  checkInteractiveMode

  print_info "Execute docker-compose"
  docker_compose::upWithProjectName $PROJECT_NAME

  print_info "Check containers status..."
  docker_compose::psWithProjectName $PROJECT_NAME

  print_info "Check container connections: apache and phpmyadmin"
  print_debug "Interactive in http://localhost:9000 to manage docker containers"
  checkInteractiveMode

  checkCleanupMode
  print_done "Poc completed successfully "
  exit 0
}

main $@
