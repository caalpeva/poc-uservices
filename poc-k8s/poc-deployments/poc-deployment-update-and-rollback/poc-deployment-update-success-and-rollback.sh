#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../../utils/uservices-utils.src"
source "${DIR}/../../../poc-docker/utils/docker.src"
source "${DIR}/../../utils/kubectl.src"

CONFIGURATION_FILE=${DIR}/config/deployment.yaml
CONFIGURATION_UPDATE_FILE=${DIR}/config/deployment-update.yaml
DEPLOYMENT_NAME="poc-deployment-update"
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

  kubectl::showNodes
  kubectl::applyWithRecord $CONFIGURATION_FILE

  kubectl::waitForDeployment $DEPLOYMENT_NAME
  kubectl::showDeployments
  kubectl::showReplicaSets
  kubectl::showPods -l "poc=$POC_LABEL_VALUE"

  print_info "Show logs..."
  POD_NAME=$(kubectl::getFirstPodName -l "poc=$POC_LABEL_VALUE")
  kubectl::showLogs $POD_NAME

  print_info "Update the deployment..."
  kubectl::apply $CONFIGURATION_UPDATE_FILE
  kubectl::showDeployments
  kubectl::showReplicaSets
  kubectl::showPods -l "poc=$POC_LABEL_VALUE"

  kubectl::showRolloutStatusFromDeployment $DEPLOYMENT_NAME && sleep 2
  kubectl::showPods

  print_info "Show logs after deployment update..."
  RUNNING_PODS=($(kubectl::getRunningPods))
  kubectl::showLogs ${RUNNING_PODS[0]}

  print_info "Check deployment update"
  declare -i POD_REPLICAS=($(kubectl::getReplicasFromDeployment $DEPLOYMENT_NAME))
  print_debug "Note that it uses a second replicaset that groups the new pods that are updated."
  print_debug "Check that at all times until the update process is finished there are always $(($POD_REPLICAS - 1)) pods available."
  print_debug "Check that the logs correspond to the updated deployment."
  checkInteractiveMode

  kubectl::showRolloutHistoryFromDeployment $DEPLOYMENT_NAME
  kubectl::rollbackDeployment $DEPLOYMENT_NAME && sleep 2
  kubectl::showDeployments
  kubectl::showReplicaSets
  kubectl::showPods -l "poc=$POC_LABEL_VALUE"

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
