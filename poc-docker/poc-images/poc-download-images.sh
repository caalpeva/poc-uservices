#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../utils/microservices-utils.src"
source "${DIR}/../utils/docker-utils.src"

#############
# VARIABLES #
#############

IMAGE_ALPINE="alpine"
IMAGE_ALPINE_3_7="$IMAGE_ALPINE:3.7"
IMAGE_ALPINE_3_8="$IMAGE_ALPINE:3.8"

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
  docker_utils::removeImages $IMAGE_ALPINE $IMAGE_ALPINE_3_7 $IMAGE_ALPINE_3_8
}

function main() {
  print_debug "$(basename $0) [PID = $$]"
  checkArguments $@

  initialize
  docker_utils::showPullUsage

  docker_utils::pullImage $IMAGE_ALPINE
  docker_utils::getImageHistory $IMAGE_ALPINE

  docker_utils::pullImage $IMAGE_ALPINE_3_7
  docker_utils::getImageHistory $IMAGE_ALPINE_3_7

  docker_utils::pullImage $IMAGE_ALPINE_3_8 "-q"
  docker_utils::getImageHistory $IMAGE_ALPINE_3_7
  
  checkCleanupMode
  print_done "Poc completed successfully "
  exit 0
}

#############
# EXECUTION #
#############

main $@
