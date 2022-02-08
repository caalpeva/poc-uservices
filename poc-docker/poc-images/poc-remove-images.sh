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
IMAGE_UBUNTU="ubuntu"
IMAGE_HTTPD="httpd"

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
  docker_utils::removeImages $IMAGE_ALPINE $IMAGE_UBUNTU $IMAGE_HTTPD
}

function main() {
  print_debug "$(basename $0) [PID = $$]"
  checkArguments $@

  initialize

  docker_utils::pullImage $IMAGE_ALPINE
  docker_utils::pullImage $IMAGE_UBUNTU
  docker_utils::pullImage $IMAGE_HTTPD
  docker_utils::getImages "-a"
  docker_utils::getImages "-aq"

  docker_utils::removeAllImages
  docker_utils::getImages
  
  checkCleanupMode
  print_done "Poc completed successfully "
  exit 0
}

#############
# EXECUTION #
#############

main $@
