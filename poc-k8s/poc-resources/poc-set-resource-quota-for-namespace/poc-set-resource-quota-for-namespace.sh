#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/progress-bar-utils.src"
source "${DIR}/../../../utils/uservices-utils.src"
source "${DIR}/../../../poc-docker/utils/docker.src"
source "${DIR}/../../utils/kubectl.src"

CONFIG_DIR=${DIR}/config
CONFIGFILE_DEPLOYMENT=${CONFIG_DIR}/deployment.yaml
CONFIGFILE_NAMESPACE=${CONFIG_DIR}/namespace.yaml
CONFIGFILE_LIMIT_RANGE=${CONFIG_DIR}/limit-range.yaml

DEPLOYMENT_NAME="poc-set-resource-quota-for-namespace"
POC_LABEL_VALUE=$DEPLOYMENT_NAME
NAMESPACE="$DEPLOYMENT_NAME-ns"

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
  kubectl::unapply $CONFIGFILE_DEPLOYMENT $CONFIGFILE_NAMESPACE
}

function main {
  print_info "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  print_box "RESOURCE QUOTA FOR NAMESPACE" \
    "" \
    " A ResourceQuota is a resource restriction policy that allows:" \
    "   - Limit the number of objects that can be created in a namespace by type." \
    "   - Impose the total amount of computing resources that objects in that namespace can consume."
  checkInteractiveMode

  kubectl::showNodes
  kubectl::apply $CONFIGFILE_NAMESPACE $CONFIGFILE_DEPLOYMENT
  kubectl::waitForDeployment $DEPLOYMENT_NAME -n $NAMESPACE
  kubectl::showDeployments -n $NAMESPACE -l "poc=$POC_LABEL_VALUE"
  kubectl::showReplicaSets -n $NAMESPACE -l "poc=$POC_LABEL_VALUE"
  kubectl::showPods -n $NAMESPACE -l "poc=$POC_LABEL_VALUE"
  kubectl::describeNamespace $NAMESPACE
  print_debug "Check that the resources used not exceed the quota configured"

  kubectl::scaleDeployment $DEPLOYMENT_NAME 2 -n $NAMESPACE
  sleep 5
  kubectl::waitForPodsByLabel -n $NAMESPACE -l "poc=$POC_LABEL_VALUE"
  kubectl::showDeployments -n $NAMESPACE -l "poc=$POC_LABEL_VALUE"
  kubectl::showReplicaSets -n $NAMESPACE -l "poc=$POC_LABEL_VALUE"
  kubectl::showPods -n $NAMESPACE -l "poc=$POC_LABEL_VALUE"
  kubectl::describeNamespace $NAMESPACE
  print_debug "Check again that the resources used not exceed the quota configured"

  kubectl::scaleDeployment $DEPLOYMENT_NAME 4 -n $NAMESPACE
  sleep 5
  kubectl::waitForPodsByLabel -n $NAMESPACE -l "poc=$POC_LABEL_VALUE"
  kubectl::showDeployments -n $NAMESPACE -l "poc=$POC_LABEL_VALUE"
  kubectl::showReplicaSets -n $NAMESPACE -l "poc=$POC_LABEL_VALUE"
  kubectl::showPods -n $NAMESPACE -l "poc=$POC_LABEL_VALUE"
  kubectl::describeNamespace $NAMESPACE

  print_info "Check that now the resources used exceed the quota configured"
  print_debug "Note that it was not possible to scale to the number of replicas specified"
  kubectl::getLastReplicaSetEventsFromDeployment $DEPLOYMENT_NAME -n $NAMESPACE
  checkInteractiveMode

  checkCleanupMode
  print_done "Poc completed successfully"
  exit 0
}

main $@
