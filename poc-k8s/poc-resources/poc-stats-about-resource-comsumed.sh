#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/progress-bar-utils.src"
source "${DIR}/../../utils/microservices-utils.src"
source "${DIR}/../../poc-docker/utils/docker.src"
source "${DIR}/../utils/kubectl.src"
source "${DIR}/./plot-utils.src"

TMP_DIRECTORY="${DIR}/tmp"

COMMON__COMPONENTS_FOR_PLOTS=poc-server poc-client
COMMON__NAMESPACE=default
COMMON__GETMETRICS_SLOT=5

function initialize() {
  print_info "Preparing poc environment..."
  setTerminalSignals
  cleanup

  if [ ! -d ${TMP_DIRECTORY} ]; then
    xtrace on
    mkdir ${TMP_DIRECTORY}
    xtrace off
  fi
}

function handleTermSignal() {
  xtrace off
  print_warn "Handling termination signal..."
  cleanup
  exit 1
}

function cleanup {
  print_debug "Cleaning environment..."
  #xtrace on
  #rm -rf ${TMP_DIRECTORY}
  #xtrace off

}

function main {
  print_info "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  get_metrics 300 $TMP_DIRECTORY
  plots $TMP_DIRECTORY

  checkCleanupMode
  print_done "Poc completed successfully"
  exit 0
}

main $@
