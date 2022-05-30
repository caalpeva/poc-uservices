#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/progress-bar-utils.src"
source "${DIR}/../../utils/microservices-utils.src"
source "${DIR}/../../poc-docker/utils/docker.src"
source "${DIR}/../utils/kubectl.src"

CONFIG_DIR=${DIR}/config
CONFIGFILE_DEPLOYMENT=${CONFIG_DIR}/deployment-service.yaml
CONFIGFILE_DEPLOYMENT_UPDATE=${CONFIG_DIR}/deployment-service-with-resources.yaml
REPLICASET_NAME="poc-replicaset"
POC_LABEL_VALUE=$REPLICASET_NAME

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
  if [ $UNINSTALL_METRICS_SERVER = true ]; then
    kubectl::unapply $CONFIGFILE_METRICS_SERVER
  fi
}

function main {
  print_info "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  kubectl::showNodes
  kubectl::apply $CONFIGFILE_METRICS_SERVER
  kubectl::waitForNodeMetrics $1 &
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
