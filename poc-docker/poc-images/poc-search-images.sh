#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../utils/uservices.src"
source "${DIR}/../utils/docker.src"

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

function main() {
  print_debug "$(basename $0) [PID = $$]"
  checkArguments $@

  initialize
  docker::showSearchUsage
  docker::searchImages "alpine"
  docker::searchOfficialImage "alpine"

  checkCleanupMode
  print_done "Poc completed successfully "
  exit 0
}

#############
# EXECUTION #
#############

main $@
