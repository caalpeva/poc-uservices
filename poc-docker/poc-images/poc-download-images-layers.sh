#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../utils/microservices-utils.src"
source "${DIR}/../utils/docker-utils.src"

#############
# VARIABLES #
#############

IMAGE_PHP="php"
IMAGE_PHP_APACHE="$IMAGE_PHP:apache"

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
  removeImages $IMAGE_PHP $IMAGE_PHP_APACHE
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

  downloadDockerImage $IMAGE_PHP
  downloadDockerImage $IMAGE_PHP_APACHE
  
  showImageHistory $IMAGE_PHP
  showImageHistory $IMAGE_PHP_APACHE

  checkCleanupMode
  print_done "Poc completed successfully "
  exit 0
}

#############
# EXECUTION #
#############

main $@
