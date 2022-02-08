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
  removeImages $IMAGE_ALPINE $IMAGE_UBUNTU $IMAGE_HTTPD
}


function showDockerImagesUsage() {
  print_info "Show docker images usage"  
  xtrace on
  docker images --help
  xtrace off
  checkInteractiveMode
}

function showDockerImageList() {
  local option=${2:-}
  print_info "Show docker images"  
  xtrace on
  docker images $option
  xtrace off
  checkInteractiveMode
}

function downloadDockerImage() {
  local option=${2:-}
  print_info "Download docker image: $1"
  xtrace on
  docker pull $1 $option
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

function removeImages() {
  print_info "Remove images: $@"
  xtrace on
  docker rmi $@
  xtrace off
  checkInteractiveMode
}

function main() {
  print_debug "$(basename $0) [PID = $$]"
  checkArguments $@

  initialize
  showDockerImagesUsage
  showDockerImageList

  downloadDockerImage $IMAGE_ALPINE
  downloadDockerImage $IMAGE_UBUNTU
  downloadDockerImage $IMAGE_HTTPD
  showDockerImageList
  
  checkCleanupMode
  print_done "Poc completed successfully "
  exit 0
}

#############
# EXECUTION #
#############

main $@
