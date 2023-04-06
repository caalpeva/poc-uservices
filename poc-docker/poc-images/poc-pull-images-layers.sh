#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../utils/uservices.src"
source "${DIR}/../utils/docker.src"

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
  docker::removeImages $IMAGE_PHP $IMAGE_PHP_APACHE
}

function main() {
  print_debug "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  docker::pullImage $IMAGE_PHP
  docker::pullImage $IMAGE_PHP_APACHE
  
  docker::getImageHistory $IMAGE_PHP
  docker::getImageHistory $IMAGE_PHP_APACHE

  checkCleanupMode
  print_done "Poc completed successfully "
  exit 0
}

#############
# EXECUTION #
#############

main $@
