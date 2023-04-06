#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../../utils/uservices-utils.src"
source "${DIR}/../../../poc-docker/utils/docker.src"
source "${DIR}/../../utils/kubectl.src"

CONFIG_DIR=${DIR}/config
CONFIGURATION_FILE=${CONFIG_DIR}/deployment.yaml
CONFIGMAP_NAME="poc-configmap-environment-file"
DEPLOYMENT_NAME=$CONFIGMAP_NAME
POC_LABEL_VALUE=$CONFIGMAP_NAME

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
  kubectl::showDeployments -l "poc=$POC_LABEL_VALUE"
  kubectl::showReplicaSets -l "poc=$POC_LABEL_VALUE"
  kubectl::showPods -l "poc=$POC_LABEL_VALUE"
  kubectl::showConfigMaps -l "poc=$POC_LABEL_VALUE"
  kubectl::showConfigMapDescription $CONFIGMAP_NAME

  print_info "Show logs..."
  POD_NAME=$(kubectl::getFirstPodName -l "poc=$POC_LABEL_VALUE")
  kubectl::showLogs $POD_NAME

  print_info "Check environment variables"
  kubectl::execUniqueContainer $POD_NAME "env"

  checkCleanupMode
  print_done "Poc completed successfully"
  exit 0
}

main $@
