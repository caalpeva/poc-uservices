#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../../utils/uservices.src"
source "${DIR}/../../../poc-docker/utils/docker.src"
source "${DIR}/../../utils/kubectl.src"

CONFIG_DIR=${DIR}/config
CONFIGURATION_FILE=${CONFIG_DIR}/deployment.yaml
DEPLOYMENT_NAME="poc-volume-emptydir"
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

  print_box "POC VOLUME EMPTYDIR" \
    "" \
    " - Check that data persistence is maintained until the pod finishes its execution."
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

  print_info "Kill the only container that has the pod"
  kubectl::execUniqueContainer $POD_NAME kill 1
  sleep 5 && kubectl::waitForReadyPod $POD_NAME

  kubectl::showPods -l "poc=$POC_LABEL_VALUE"
  print_debug "Check that the pod has not been deleted, only the container inside it has been restarted."

  print_info "Show logs again..."
  print_debug "Check that the count of the number of files does not start from zero."
  print_debug "Therefore the volume has not been deleted during the container restart."
  kubectl::showLogs $POD_NAME

  print_info "Check files"
  kubectl::execUniqueContainer $POD_NAME ls /srv/poc-app/files

  print_info "Now, delete the pod"
  kubectl::forceDeletePod $POD_NAME
  kubectl::waitForPodsByLabel -l "poc=$POC_LABEL_VALUE"
  kubectl::showPods -l "poc=$POC_LABEL_VALUE"

  print_info "Wait for a few seconds to show logs..."
  print_debug "Check that the count of the number of files starts from zero."
  print_debug "Therefore the volume has been deleted after deleting the pod."
  POD_NAME=$(kubectl::getRunningPods -l "poc=$POC_LABEL_VALUE" | grep ^$DEPLOYMENT_NAME)
  sleep 5 && kubectl::showLogs $POD_NAME

  print_info "Check files"
  kubectl::execUniqueContainer $POD_NAME ls /srv/poc-app/files

  checkCleanupMode
  print_done "Poc completed successfully"
  exit 0
}

main $@
