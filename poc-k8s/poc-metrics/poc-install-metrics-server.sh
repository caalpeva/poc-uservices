#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/progress-bar-utils.src"
source "${DIR}/../../utils/microservices-utils.src"
source "${DIR}/../../poc-docker/utils/docker.src"
source "${DIR}/../utils/kubectl.src"

CONFIGFILE_METRICS_SERVER=${DIR}/components/metrics-server.yaml

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

function cleanup {
  print_debug "Cleaning environment..."
  kubectl::unapply $CONFIGFILE_METRICS_SERVER
}

function main {
  print_info "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  kubectl::showNodes
  kubectl::apply $CONFIGFILE_METRICS_SERVER

  print_info "Show the resource consumption of the nodes"
  kubectl::waitForNodeMetrics &
  PID=$!
  showProgressBar $PID
  wait $PID
  if [ $? -ne 0 ]; then
    print_error "Timeout. Metrics server unavailable"
    cleanup
    exit 1
  fi

  checkCleanupMode
  print_done "Poc completed successfully"
  exit 0
}

main $@
