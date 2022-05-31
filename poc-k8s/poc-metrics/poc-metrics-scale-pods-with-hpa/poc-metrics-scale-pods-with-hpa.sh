#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/progress-bar-utils.src"
source "${DIR}/../../../utils/microservices-utils.src"
source "${DIR}/../../../poc-docker/utils/docker.src"
source "${DIR}/../../utils/kubectl.src"

CONFIG_DIR=${DIR}/config
CONFIGFILE_DEPLOYMENT=${CONFIG_DIR}/deployment-service.yaml
CONFIGFILE_HORIZONTAL_POD_AUTOSCALER=${CONFIG_DIR}/hpa.yaml

DEPLOYMENT_CLIENT_NAME="poc-client"
DEPLOYMENT_SERVER_NAME="poc-server"
POC_LABEL_VALUE="poc-metrics-hpa"

REPLICAS_EXPECTED=6

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
    $CONFIGFILE_HORIZONTAL_POD_AUTOSCALER
  kubectl::resetMetricsServer
}

function main {
  print_info "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  kubectl::showNodes
  kubectl::apply $CONFIGFILE_DEPLOYMENT
  kubectl::waitForDeployment $DEPLOYMENT_SERVER_NAME
  kubectl::waitForDeployment $DEPLOYMENT_CLIENT_NAME
  kubectl::showDeployments
  kubectl::showReplicaSets
  kubectl::showPods -l "poc=$POC_LABEL_VALUE"

  print_info "Show the resource consumption of the pods"
  kubectl::showPodMetrics
  kubectl::resetMetricsServer

  print_info "Simular demanda de peticiones"
  kubectl::scaleDeployment $DEPLOYMENT_CLIENT_NAME $REPLICAS_EXPECTED && sleep 2
  kubectl::waitForDeployment $DEPLOYMENT_SERVER_NAME && sleep 2
  kubectl::waitForDeployment $DEPLOYMENT_CLIENT_NAME && sleep 2
  kubectl::showDeployments
  kubectl::showReplicaSets
  kubectl::showPods -l "poc=$POC_LABEL_VALUE"

  print_info "Show the resource consumption of the pods"
  kubectl::showPodMetrics
  kubectl::resetMetricsServer

  print_info "Configure horizontal pod autoscaler for server deployment"
  kubectl::apply $CONFIGFILE_HORIZONTAL_POD_AUTOSCALER && sleep 2
  kubectl::waitForDeployment $DEPLOYMENT_SERVER_NAME && sleep 2
  kubectl::waitForDeployment $DEPLOYMENT_CLIENT_NAME && sleep 2
  kubectl::showDeployments
  kubectl::showReplicaSets
  kubectl::showPods -l "poc=$POC_LABEL_VALUE"

  print_info "Show the resource consumption of the pods"
  kubectl::showPodMetrics

  print_info "Check resource limits"
  print_debug "Note that CPU consumption never exceed the configured CPU limit"
  print_debug "Verify that when memory consumption exceeds the configured RAM limit the pod restarts"
  checkInteractiveMode

  checkCleanupMode
  print_done "Poc completed successfully"
  exit 0
}

main $@
