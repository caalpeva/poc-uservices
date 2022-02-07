#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../utils/docker-utils.src"
source "${DIR}/../../utils/microservices-utils.src"

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
  echo "cleanup"
}


function executeContainers() {
  print_info "Execute containers..."  
  xtrace on
  docker run -dit \
    --name ${CONTAINER1_NAME} \
    ubuntu /usr/bin/top -b

  docker run -dit \
    --name ${CONTAINER3_NAME} \
    ubuntu /usr/bin/top -b

  docker run -dit \
    --rm \
    --name ${CONTAINER2_NAME} \
    ubuntu /usr/bin/top -b
  
  docker run -dit \
    --rm \
    --name ${CONTAINER4_NAME} \
    ubuntu /usr/bin/top -b

  xtrace off
}

function main() {
  print_info "$(basename $0) [PID = $$]"
  initialize
  checkArguments $@

  checkInteractiveMode

  print_done "Poc completed successfully "
  exit 0
}

main $@
