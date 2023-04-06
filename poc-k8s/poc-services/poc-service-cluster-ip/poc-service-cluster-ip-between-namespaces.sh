#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../../utils/uservices-utils.src"
source "${DIR}/../../../poc-docker/utils/docker.src"
source "${DIR}/../../utils/kubectl.src"

CONFIG_DIR=${DIR}/config
CONFIGURATION_FILE=${CONFIG_DIR}/deployments-between-namespaces.yaml
DEPLOYMENT_CLIENT_NAME="poc-client"
DEPLOYMENT_SERVER_NAME="poc-server"
SERVICE_NAME="poc-service"
POC_LABEL_VALUE="poc-service-cluster-ip"
NAMESPACE_CLIENT="ns-client"
NAMESPACE_SERVER="ns-server"

IMAGE="poc-golang-server-client"
SNAPSHOT="1.0-snapshot"
TAG="1.0"

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
  kubectl::waitForDeployment $DEPLOYMENT_SERVER_NAME
  kubectl::waitForDeployment $DEPLOYMENT_CLIENT_NAME && sleep 10
  kubectl::showDeploymentsInAllNamespaces -l "poc=$POC_LABEL_VALUE"
  kubectl::showReplicaSetsInAllNamespaces -l "poc=$POC_LABEL_VALUE"
  kubectl::showPodsInAllNamespaces -l "poc=$POC_LABEL_VALUE"
  kubectl::showServicesInAllNamespaces -l "poc=$POC_LABEL_VALUE"
  kubectl::showEndpointsByService $SERVICE_NAME -n $NAMESPACE_SERVER

  print_info "Show logs from client pod..."
  POD_NAME=$(kubectl::getFirstPodName -n $NAMESPACE_CLIENT -l "app=$DEPLOYMENT_CLIENT_NAME")
  kubectl::showLogs $POD_NAME -n $NAMESPACE_CLIENT

  checkCleanupMode
  print_done "Poc completed successfully"
  exit 0
}

main $@
