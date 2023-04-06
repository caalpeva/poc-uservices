#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/progress-bar-utils.src"
source "${DIR}/../../utils/uservices-utils.src"
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

  print_box "METRICS SERVER INSTALLATION" \
    "" \
    " - Installs the kubernetes metrics service that allows you to collect information about CPU and RAM."
  checkInteractiveMode

  kubectl::showNodes
  kubectl::apply $CONFIGFILE_METRICS_SERVER

  print_info "Show the resource consumption of the nodes"
  kubectl::showNodeMetrics

  checkCleanupMode
  print_done "Poc completed successfully"
  exit 0
}

main $@
