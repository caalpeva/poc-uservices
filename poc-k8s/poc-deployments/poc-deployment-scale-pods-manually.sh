#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../utils/microservices-utils.src"
source "${DIR}/../../poc-docker/utils/docker.src"
source "${DIR}/../utils/kubectl.src"

CONFIGURATION_FILE=${DIR}/config/deployment.yaml
DEPLOYMENT_NAME="poc-deployment"
LABEL_NAME="poc-deployment"

REPLICAS_EXPECTED=5

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
  sleep 20
  kubectl::waitForPodsByLabel "name=$LABEL_NAME"
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
  checkInteractiveMode

  checkCleanupMode
  print_done "Poc completed successfully"
  exit 0
}

main $@
