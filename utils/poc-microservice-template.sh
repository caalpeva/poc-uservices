#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../utils/microservices-utils.src"

#############
# VARIABLES #
#############


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

  print_done "Poc completed successfully "
  exit 0
}

main $@
