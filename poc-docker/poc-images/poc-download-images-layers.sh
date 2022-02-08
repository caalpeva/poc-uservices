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


function downloadDockerImage() {
  local option=${2:-}
  print_info "Download docker image: $1"
  xtrace on
  docker pull $1 $option
  xtrace off
  checkInteractiveMode
}

function showDockerHistoryUsage() {
  print_info "Show docker history usage"  
  xtrace on
  docker history --help
  xtrace off
  checkInteractiveMode
}

function showImageHistory() {
  local option=${2:-}
  print_info "Show docker image history: $1"
  xtrace on
  docker history $1 $option
  xtrace off
  checkInteractiveMode
}

function main() {
  print_debug "$(basename $0) [PID = $$]"
  checkArguments $@

  initialize
  local image="php"
  downloadDockerImage $image
  downloadDockerImage "$image:apache"
  showImageHistory $image
  showImageHistory "$image:apache"

  checkCleanupMode
  print_done "Poc completed successfully "
  exit 0
}

#############
# EXECUTION #
#############

main $@
