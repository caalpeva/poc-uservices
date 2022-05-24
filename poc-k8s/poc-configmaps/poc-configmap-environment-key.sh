#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../utils/microservices-utils.src"
source "${DIR}/../../poc-docker/utils/docker.src"
source "${DIR}/../utils/kubectl.src"

CONFIGURATION_FILE=${DIR}/config/deployment-configmap-environment-key.yaml
CONFIGMAP_NAME="poc-configmap-environment-key"
DEPLOYMENT_NAME="poc-configmap-environment-key"
LABEL_NAME="poc-configmap-environment-key"

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

  kubectl::showNodes
  kubectl::apply $CONFIGURATION_FILE

  kubectl::waitForDeployment $DEPLOYMENT_NAME
  kubectl::showDeployments -l "poc=$LABEL_NAME"
  kubectl::showReplicaSets -l "poc=$LABEL_NAME"
  kubectl::showPods -l "poc=$LABEL_NAME"
  kubectl::showConfigMaps -l "poc=$LABEL_NAME"
  kubectl::showConfigMapDescription $CONFIGMAP_NAME

  print_info "Show logs..."
  POD_NAME=$(kubectl::getFirstPodName -l "poc=$LABEL_NAME")
  kubectl::showLogs $POD_NAME

  checkCleanupMode
  print_done "Poc completed successfully"
  exit 0
}

main $@
