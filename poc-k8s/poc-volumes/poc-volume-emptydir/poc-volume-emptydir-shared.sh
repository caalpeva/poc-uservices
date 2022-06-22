#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../../utils/microservices-utils.src"
source "${DIR}/../../../poc-docker/utils/docker.src"
source "${DIR}/../../utils/kubectl.src"

CONFIG_DIR=${DIR}/config
CONFIGURATION_FILE=${CONFIG_DIR}/deployments-with-volume-shared.yaml
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
    " - Check that data persistence is maintained until the pod finishes its execution." \
    " - Check that the containers can share files with each other."
  checkInteractiveMode

  kubectl::showNodes

  kubectl::apply $CONFIGURATION_FILE
  kubectl::waitForDeployment $DEPLOYMENT_NAME
  kubectl::showPods -l "poc=$POC_LABEL_VALUE"

  print_info "Wait for a few seconds to show logs..."
  print_debug "Note that file generation will be faster in container 2"
  POD_NAME=$(kubectl::getRunningPods -l "poc=$POC_LABEL_VALUE" | grep ^$DEPLOYMENT_NAME)
  sleep 5 && kubectl::showLogsByContainer $POD_NAME $CONTAINER1_NAME
  kubectl::showLogsByContainer $POD_NAME $CONTAINER2_NAME

  print_info "Check files"
  print_debug "Note that the same files is displayed in both containers at the same time,"
  print_debug "except for concurrency problems."
  kubectl::execContainer $POD_NAME $CONTAINER1_NAME ls /srv/poc-app/files
  kubectl::execContainer $POD_NAME $CONTAINER2_NAME ls /srv/poc-app/files

  checkCleanupMode
  print_done "Poc completed successfully"
  exit 0
}

main $@
