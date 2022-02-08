#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../utils/microservices-utils.src"
source "${DIR}/../utils/docker-utils.src"

#############
# VARIABLES #
#############

CONTAINER_PREFIX="poc_ubuntu_top$(date '+%Y%m%d')"
CONTAINER1_NAME="${CONTAINER_PREFIX}_1"

#############
# FUNCTIONS #
#############

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

function cleanup() {
  print_debug "Cleaning environment..."
}


function showDockerSearchUsage() {
  print_info "Show docker search usage"  
  xtrace on
  docker search --help
  xtrace off
  checkInteractiveMode
}

function searchDockerImage() {
  print_info "Search docker image: $1"
  xtrace on
  docker search $1 --limit 5
  xtrace off
  checkInteractiveMode
}

function searchDockerOfficialImage() {
  print_info "Search docker official image: $1"
  xtrace on
  docker search --filter is-official=true $1
  xtrace off
}

function main() {
  print_debug "$(basename $0) [PID = $$]"
  checkArguments $@

  initialize
  showDockerSearchUsage
  searchDockerImage "alpine"
  searchDockerOfficialImage "alpine"

  checkCleanupMode
  print_done "Poc completed successfully "
  exit 0
}

#############
# EXECUTION #
#############

main $@
