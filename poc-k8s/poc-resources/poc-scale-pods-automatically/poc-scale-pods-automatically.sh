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

  print_box "HORIZONTAL POD AUTOSCALER" \
    "" \
    " - Checks the deployment behavior when using horizontal pod autoscaler."
  checkInteractiveMode

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

  print_info "Simulate the increase in demand for client requests"
  kubectl::scaleDeployment $DEPLOYMENT_CLIENT_NAME $REPLICAS_EXPECTED
  kubectl::waitForDeployment $DEPLOYMENT_SERVER_NAME && sleep 2
  kubectl::waitForDeployment $DEPLOYMENT_CLIENT_NAME && sleep 2
  kubectl::showDeployments
  kubectl::showReplicaSets
  kubectl::showPods -l "poc=$POC_LABEL_VALUE"

  print_info "Show the resource consumption of the pods again"
  print_debug "Note that the server CPU consumption has increased due to the saturation of requests."
  print_debug "Note that the CPU consumption of the clients is less than usual, due to the fact"
  print_debug "the server cannot respond to all the requests, causing the clients to wait,"
  print_debug "even on some occasions it is possible that a client restarts."
  kubectl::showPodMetrics
  # Do not reset at this point, because to scale automatically it needs the availability of metrics
  #kubectl::resetMetricsServer

  print_info "Configure horizontal pod autoscaler for deployment server"
  print_debug "In this way, the number of server pods will automatically increase"
  print_debug "until it can satisfy the requests of the clients."
  kubectl::apply $CONFIGFILE_HORIZONTAL_POD_AUTOSCALER
  sleep 20
  kubectl::waitForDeployment $DEPLOYMENT_SERVER_NAME
  kubectl::waitForDeployment $DEPLOYMENT_CLIENT_NAME
  kubectl::showDeployments
  kubectl::showReplicaSets
  kubectl::showPods -l "poc=$POC_LABEL_VALUE"

  print_info "Show the resource consumption of the pods after server autoscaling"
  print_debug "Note that when the number of servers have increased, the clients will again consume more CPU."
  print_debug "Also note the CPU consumption of servers have decreased because the client requests are distributed."
  kubectl::resetMetricsServer
  kubectl::showPodMetrics

  print_info "Show horizontal pod autoscalers"
  print_debug "Observe the server CPU consumption and increase the number of pods if necessary"
  kubectl::getHorizontalPodAutoscaler -l "poc=$POC_LABEL_VALUE"

  print_info "Check the autoscaled of server pods"
  POD_REPLICAS=$(kubectl::getReplicasFromDeployment $DEPLOYMENT_SERVER_NAME)
  if [ $POD_REPLICAS -eq 1 ]; then
      print_error "Poc completed with failure. Pod replicas is greater than 1."
      checkCleanupMode
  fi
  print_debug "Check that the number of server pod replicas has changed ($POD_REPLICAS)"

  checkCleanupMode
  print_done "Poc completed successfully"
  exit 0
}

main $@
