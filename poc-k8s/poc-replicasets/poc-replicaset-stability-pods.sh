#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../utils/microservices-utils.src"
source "${DIR}/../../poc-docker/utils/docker.src"
source "${DIR}/../utils/kubectl.src"

CONFIG_DIR=${DIR}/config
CONFIGURATION_FILE=${CONFIG_DIR}/replicaset.yaml
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
  kubectl::unapply $CONFIGURATION_FILE
}

function main {
  print_info "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  kubectl::showNodes
  kubectl::apply $CONFIGURATION_FILE
  kubectl::waitForPodsByLabel -l "poc=$POC_LABEL_VALUE"
  kubectl::showReplicaSets
  kubectl::showPods

  print_info "Delete a pod"
  POD_NAME=$(kubectl::getFirstPodName)
  kubectl::forceDeletePod $POD_NAME
  checkInteractiveMode

  kubectl::showPods

  print_info "Check the stability of pods"
  POD_NUMBER=($(kubectl::getPodNames))
  POD_REPLICAS=$(kubectl::getReplicasFromReplicaSet $REPLICASET_NAME)
  if [ ${#POD_NUMBER[@]} -ne $POD_REPLICAS ]; then
    print_error "Poc completed with failure. Pod replicas is not $POD_REPLICAS."
    exit 1
  fi

  print_debug "Check the number of pods is always equal to the number of replicas ($POD_REPLICAS)"
  print_debug "Pod $POD_NAME was deleted but a new one was created in its place"
  checkInteractiveMode

  checkCleanupMode
  print_done "Poc completed successfully"
  exit 0
}

main $@
