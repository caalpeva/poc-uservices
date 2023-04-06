#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../../utils/uservices-utils.src"
source "${DIR}/../../../poc-docker/utils/docker.src"
source "${DIR}/../../utils/kubectl.src"

CONFIG_DIR=${DIR}/config
CONFIGURATION_FILE=${CONFIG_DIR}/deployment.yaml
DEPLOYMENT_CLIENT_NAME="poc-client"
DEPLOYMENT_SERVER_NAME="poc-server"
SERVICE_NAME="poc-service"
POC_LABEL_VALUE="poc-service-cluster-ip"
LOCAL_PORT=9999

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

  print_box "KUBERNETES PORT-FORWARD" \
    "" \
    "The kubectl port-forward command allows you to forward traffic from a local machine port" \
    "to the port of a pod or service exposed by the application."
  checkInteractiveMode

  kubectl::showNodes
  kubectl::apply $CONFIGURATION_FILE
  kubectl::waitForDeployment $DEPLOYMENT_SERVER_NAME
  kubectl::waitForDeployment $DEPLOYMENT_CLIENT_NAME && sleep 10
  kubectl::showDeployments -l "poc=$POC_LABEL_VALUE"
  kubectl::showReplicaSets -l "poc=$POC_LABEL_VALUE"
  kubectl::showPods -l "poc=$POC_LABEL_VALUE"
  kubectl::showServices -l "poc=$POC_LABEL_VALUE"
  kubectl::showEndpointsByService $SERVICE_NAME

  print_info "Extract port from service"
  SERVICE_PORT=$(kubectl::getPortByService ${SERVICE_NAME} http-server)
  checkInteractiveMode

  print_info "Forward local port to service port"
  evalCommand kubectl port-forward service/${SERVICE_NAME} --address 0.0.0.0 ${LOCAL_PORT}:${SERVICE_PORT} "&"
  PID=$!
  checkInteractiveMode

  sleep 3
  SERVER_AVAILABLE=true
  print_info "Make requests from local port..."
  for i in {1..3}
  do
    executeCurl http://localhost:$LOCAL_PORT/echo
    if [ $? -ne 0 ]
    then
      print_error "Http server is not available"
      SERVER_AVAILABLE=false
    fi
  done
  checkInteractiveMode

  print_info "Kill the execution of the port-forward command"
  xtrace on
  kill -9 $PID
  xtrace off
  checkCleanupMode

  if [ $SERVER_AVAILABLE = false ]; then
    print_error "Poc completed with failure"
    exit 1
  fi

  checkCleanupMode
  print_done "Poc completed successfully"
  exit 0
}

main $@
