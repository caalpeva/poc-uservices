#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/progress-bar-utils.src"
source "${DIR}/../../../utils/microservices-utils.src"
source "${DIR}/../../../poc-docker/utils/docker.src"
source "${DIR}/../../utils/kubectl.src"

CONFIG_DIR=${DIR}/config
CONFIGFILE_DEPLOYMENT=${CONFIG_DIR}/deployment.yaml
CONFIGFILE_NAMESPACE=${CONFIG_DIR}/namespace.yaml
CONFIGFILE_LIMIT_RANGE=${CONFIG_DIR}/limit-range.yaml

DEPLOYMENT1_NAME="poc-limit-range-for-container-resources-01"
DEPLOYMENT2_NAME="poc-limit-range-for-container-resources-02"
POC_LABEL_VALUE="poc-limit-range-for-container-resources"
NAMESPACE="$POC_LABEL_VALUE-ns"

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
    $CONFIGFILE_LIMIT_RANGE
    #$CONFIGFILE_NAMESPACE
}

function main {
  print_info "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  echo "el namespace es: $NAMESPACE"
  print_box "LIMIT CPU AND MEMORY RESOURCES FROM NAMESPACE" \
    "" \
    " - Checks the deployment behavior when CPU and RAM resources are limited with LimitRange from namespaces."
  checkInteractiveMode

  kubectl::showNodes
  kubectl::apply $CONFIGFILE_LIMIT_RANGE \
    $CONFIGFILE_DEPLOYMENT
    #$CONFIGFILE_NAMESPACE \
  kubectl::waitForDeployment $DEPLOYMENT1_NAME -n $NAMESPACE
  kubectl::showDeployments -n $NAMESPACE -l "poc=$POC_LABEL_VALUE"
  kubectl::showReplicaSets -n $NAMESPACE -l "poc=$POC_LABEL_VALUE"
  kubectl::showPods -n $NAMESPACE -l "poc=$POC_LABEL_VALUE"

  kubectl::describeNamespace $NAMESPACE

  print_info "Check resource constraints configured in pod containers"
  print_debug "Note that default resource values will be applied to the containers"
  print_debug "that have not resource constraints configured"
  POD_NAME=$(kubectl::getPodNames -n $NAMESPACE -l "poc=$POC_LABEL_VALUE")
  kubectl::getResourceLimitFromPod $POD_NAME -n $NAMESPACE
  checkInteractiveMode

  print_info "Check the maximum and minimum limits of the resources"
  print_debug "Note that second deployment could not be started"
  print_debug "The requested resources are outside the limits allowed"
  checkInteractiveMode

  checkCleanupMode
  print_done "Poc completed successfully"
  exit 0
}

main $@
