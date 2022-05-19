#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../utils/microservices-utils.src"
source "${DIR}/../../poc-docker/utils/docker.src"
source "${DIR}/../utils/kubectl.src"

CONFIGURATION_FILE=${DIR}/deployment.yaml
CONFIGURATION_UPDATE_FILE=${DIR}/deployment-update-bad.yaml
DEPLOYMENT_NAME="poc-deployment"
LABEL_NAME="poc-deployment"

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
  kubectl::showPodsByLabel "name=$LABEL_NAME"

  print_info "Show logs..."
  POD_NAME=$(kubectl::getFirstPodNameByLabel "name=$LABEL_NAME")
  kubectl::showLogs $POD_NAME

  print_info "Update the deployment..."
  kubectl::apply $CONFIGURATION_UPDATE_FILE && sleep 5
  kubectl::showDeployments
  kubectl::showReplicaSets
  kubectl::showPods

  print_info "Check deployment update failed"
  print_debug "Note that logs cannot be displayed because the image is wrong."
  checkInteractiveMode

  kubectl::rollbackDeployment $DEPLOYMENT_NAME && sleep 2
  kubectl::showDeployments
  kubectl::showReplicaSets
  kubectl::showPods

  kubectl::showRolloutStatusFromDeployment $DEPLOYMENT_NAME && sleep 2
  kubectl::showPods

  print_info "Show logs after deployment rollback..."
  RUNNING_PODS=($(kubectl::getRunningPods))
  kubectl::showLogs ${RUNNING_PODS[0]}

  print_info "Check deployment rollback"
  print_debug "Note that changes are reverted using the previous replicaset."
  print_debug "Check that the logs correspond to the initial deployment."
  checkInteractiveMode

  checkCleanupMode
  print_done "Poc completed successfully"
  exit 0
}

main $@
