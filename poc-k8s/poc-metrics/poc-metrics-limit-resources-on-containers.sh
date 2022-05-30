#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/progress-bar-utils.src"
source "${DIR}/../../utils/microservices-utils.src"
source "${DIR}/../../poc-docker/utils/docker.src"
source "${DIR}/../utils/kubectl.src"

CONFIG_DIR=${DIR}/config
CONFIGFILE_DEPLOYMENT=${CONFIG_DIR}/deployment-service.yaml
CONFIGFILE_DEPLOYMENT_UPDATE=${CONFIG_DIR}/deployment-service-with-resources.yaml

DEPLOYMENT_CLIENT_NAME="poc-client"
DEPLOYMENT_SERVER_NAME="poc-server"
POC_LABEL_VALUE="poc-metrics-hpa"

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
  kubectl::unapply $CONFIGFILE_DEPLOYMENT_UPDATE $CONFIGFILE_DEPLOYMENT
}

function main {
  print_info "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  kubectl::showNodes
  kubectl::apply $CONFIGFILE_DEPLOYMENT
  kubectl::waitForDeployment $DEPLOYMENT_SERVER_NAME
  kubectl::waitForDeployment $DEPLOYMENT_CLIENT_NAME && sleep 10
  kubectl::showDeployments
  kubectl::showReplicaSets
  kubectl::showPods -l "poc=$POC_LABEL_VALUE"

  print_info "Show the resource consumption of the pods"
  kubectl::waitForPodMetrics &
  PID=$!
  showProgressBar $PID
  wait $PID
  if [ $? -ne 0 ]; then
    print_error "Timeout. Metrics server unavailable"
    cleanup
    exit 1
  fi

  print_info "Update the deployment with the resources limited"
  kubectl::apply $CONFIGFILE_DEPLOYMENT_UPDATE && sleep 5
  kubectl::showDeployments
  kubectl::showReplicaSets
  kubectl::showPods -l "poc=$POC_LABEL_VALUE" && sleep 5

  print_info "Note the memory limit configured on the client pod container"
  print_debug "This value is insufficient for the correct operation of the pod"
  kubectl::showPodMemoryLimitFromDeployment $DEPLOYMENT_CLIENT_NAME

  print_info "Show the resource consumption of the pods again"
  kubectl::waitForPodMetrics &
  PID=$!
  showProgressBar $PID
  wait $PID
  if [ $? -ne 0 ]; then
    print_error "Timeout. Metrics server unavailable"
    cleanup
    exit 1
  fi

  print_info "Wait for the pod to restart"
  kubectl::waitForPodRestarted $DEPLOYMENT_CLIENT_NAME
  kubectl::showPods -l "poc=$POC_LABEL_VALUE"

  print_info "Show the resource consumption of the pods again"
  kubectl::waitForPodMetrics &
  PID=$!
  showProgressBar $PID
  wait $PID
  if [ $? -ne 0 ]; then
    print_error "Timeout. Metrics server unavailable"
    cleanup
    exit 1
  fi

  print_info "Check the limits of the configured resources"
  print_debug "Check that cpu consumption does not exceed the configured limit."
  print_debug "Check that after a while the container exceeds the configured memory limit and therefore the pod that contains it is restarted."
  checkInteractiveMode

  checkCleanupMode
  print_done "Poc completed successfully"
  exit 0
}

main $@
