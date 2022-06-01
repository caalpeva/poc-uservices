#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../../utils/microservices-utils.src"
source "${DIR}/../../../poc-docker/utils/docker.src"
source "${DIR}/../../utils/kubectl.src"

CONFIGURATION_FILE=${DIR}/deployment-volume.yaml
DEPLOYMENT_NAME="poc-volume-persistent"
POC_LABEL_VALUE=$DEPLOYMENT_NAME

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

  print_box "POC VOLUME HOSTPATH" \
    "" \
    " - Checks the deployment behavior when using horizontal pod autoscaler."
  checkInteractiveMode

  kubectl::showNodes

  kubectl::apply $CONFIGURATION_FILE
  kubectl::waitForDeployment $DEPLOYMENT_NAME
  kubectl::showPods -l "poc=$POC_LABEL_VALUE"

  print_info "Wait for a few seconds to show logs..."
  sleep 5 && POD_NAME=$(kubectl::getRunningPods -l "poc=$POC_LABEL_VALUE" | grep ^$DEPLOYMENT_NAME)
  kubectl::showLogs $POD_NAME

  print_info "Check files"
  kubectl::execUniqueContainer $POD_NAME ls /srv/poc-app/files

  print_info "Now, delete the pod"
  kubectl::forceDeletePod $POD_NAME
  kubectl::waitForPodsByLabel -l "poc=$POC_LABEL_VALUE"
  kubectl::showPods -l "poc=$POC_LABEL_VALUE"

  print_info "Wait for a few seconds to show logs..."
  print_debug "Confirm that the volume has not been deleted."
  POD_NAME=$(kubectl::getRunningPods -l "poc=$POC_LABEL_VALUE" | grep ^$DEPLOYMENT_NAME)
  sleep 5 && kubectl::showLogs $POD_NAME

  print_info "Check files"
  kubectl::execUniqueContainer $POD_NAME ls /srv/poc-app/files

  checkCleanupMode
  print_done "Poc completed successfully"
  exit 0
}

main $@
