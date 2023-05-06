#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../../utils/uservices.src"
source "${DIR}/../../../poc-docker/utils/docker.src"
source "${DIR}/../../utils/kubectl.src"

CONFIG_DIR=${DIR}/config
CONFIGURATION_FILE=${CONFIG_DIR}/deployment.yaml
DEPLOYMENT_NAME="poc-deployment-scale-manual"
POC_LABEL_VALUE=$DEPLOYMENT_NAME

REPLICAS_EXPECTED=4

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
  kubectl::showDeployments
  kubectl::showReplicaSets
  kubectl::showPods

  kubectl::scaleDeployment $DEPLOYMENT_NAME $REPLICAS_EXPECTED
  sleep 15
  kubectl::waitForPodsByLabel -l "poc=$POC_LABEL_VALUE"
  kubectl::showDeployments
  kubectl::showReplicaSets
  kubectl::showPods

  print_info "Check the scaled of pods"
  POD_NUMBER=($(kubectl::getPodNames))
  POD_REPLICAS=$(kubectl::getReplicasFromDeployment $DEPLOYMENT_NAME)
  if [ ${#POD_NUMBER[@]} -ne $REPLICAS_EXPECTED -o $POD_REPLICAS -ne $REPLICAS_EXPECTED ]; then
    print_error "Poc completed with failure. Pod replicas is not $REPLICAS_EXPECTED."
    exit 1
  fi
  print_debug "Check that the number of pod replicas has changed ($POD_REPLICAS)"

  checkCleanupMode
  print_done "Poc completed successfully"
  exit 0
}

main $@
