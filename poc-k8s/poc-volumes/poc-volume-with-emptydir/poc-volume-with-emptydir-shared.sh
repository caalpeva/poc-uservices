#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../../utils/microservices-utils.src"
source "${DIR}/../../../poc-docker/utils/docker.src"
source "${DIR}/../../utils/kubectl.src"

CONFIGURATION_FILE=${DIR}/config/deployment-volume-shared.yaml
DEPLOYMENT_NAME="poc-volume-emptydir-shared"
POC_LABEL_VALUE=$DEPLOYMENT_NAME
CONTAINER1_NAME="$DEPLOYMENT_NAME-1"
CONTAINER2_NAME="$DEPLOYMENT_NAME-2"

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
  kubectl::unapply $CONFIGURATION_FILE
}

function main {
  print_info "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  print_box "POC VOLUME EMPTYDIR SHARED" \
    "" \
    " - Checks the deployment behavior when using horizontal pod autoscaler."
  checkInteractiveMode

  kubectl::showNodes

  kubectl::apply $CONFIGURATION_FILE
  kubectl::waitForDeployment $DEPLOYMENT_NAME
  kubectl::showPods -l "poc=$POC_LABEL_VALUE"

  print_info "Wait for a few seconds to show logs..."
  POD_NAME=$(kubectl::getRunningPods -l "poc=$POC_LABEL_VALUE" | grep ^$DEPLOYMENT_NAME)
  sleep 5 && kubectl::showLogsByContainer $POD_NAME $CONTAINER1_NAME
  kubectl::showLogsByContainer $POD_NAME $CONTAINER2_NAME

  print_info "Check files"
  kubectl::execContainer $POD_NAME $CONTAINER1_NAME ls /srv/poc-app/files
  kubectl::execContainer $POD_NAME $CONTAINER2_NAME ls /srv/poc-app/files

  checkCleanupMode
  print_done "Poc completed successfully"
  exit 0
}

main $@
