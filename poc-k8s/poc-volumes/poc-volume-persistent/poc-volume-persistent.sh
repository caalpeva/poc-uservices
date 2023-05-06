#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../../utils/uservices.src"
source "${DIR}/../../../poc-docker/utils/docker.src"
source "${DIR}/../../utils/kubectl.src"

CONFIG_DIR=${DIR}/config
CONFIGFILE_DEPLOYMENT=${CONFIG_DIR}/deployment.yaml
CONFIGFILE_PERSISTENT_VOLUMES=${CONFIG_DIR}/persistentvolumes.yaml
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
  kubectl::unapply $CONFIGFILE_DEPLOYMENT \
    $CONFIGFILE_PERSISTENT_VOLUMES
}

function main {
  print_info "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  print_box "POC PERSISTENT VOLUME" \
    "" \
    " - Checks the deployment behavior when using PV and PVC."
  checkInteractiveMode

  kubectl::showNodes

  kubectl::apply $CONFIGFILE_PERSISTENT_VOLUMES
  print_info "Show persistent volumes"
  kubectl::showPersistentVolumes

  kubectl::apply $CONFIGFILE_DEPLOYMENT
  kubectl::waitForDeployment $DEPLOYMENT_NAME
  print_info "Show persistent volume claims"
  print_debug "Checks that the state is bound since the storage demand is satisfied"
  kubectl::showPersistentVolumeClaims
  kubectl::showPods -l "poc=$POC_LABEL_VALUE"

  print_info "Wait for a few seconds to show logs..."
  sleep 5 && POD_NAME=$(kubectl::getRunningPods -l "poc=$POC_LABEL_VALUE" | grep ^$DEPLOYMENT_NAME)
  kubectl::showLogs $POD_NAME

  print_info "Check files"
  kubectl::execUniqueContainer $POD_NAME ls /srv/poc-app/files

  print_info "Show persistent volumes again"
  print_debug "Note that the assigned volume was the one with the closest storage capacity to the requested volume"
  kubectl::showPersistentVolumes

  checkCleanupMode
  print_done "Poc completed successfully"
  exit 0
}

main $@
