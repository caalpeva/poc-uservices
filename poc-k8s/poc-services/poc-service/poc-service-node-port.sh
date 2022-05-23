#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../../utils/microservices-utils.src"
source "${DIR}/../../../poc-docker/utils/docker.src"
source "${DIR}/../../utils/kubectl.src"

FLAG_CREATE_AND_PUSH_IMAGE=false

CONFIGURATION_FILE=${DIR}/deployment-service-node-port.yaml
DEPLOYMENT_CLIENT_NAME="poc-client"
DEPLOYMENT_SERVER_NAME="poc-server"
SERVICE_NAME="poc-service"
POC_LABEL_VALUE="poc-service-node-port"

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
  images=($(docker::getImagesWithTags $IMAGE))
  if [ ${#images[@]} -gt 0 ]; then
    docker::removeImages ${images[*]}
  fi
}

function main {
  print_info "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  kubectl::showNodes

  if [ $FLAG_CREATE_AND_PUSH_IMAGE = true ]; then
    print_info "Filter images by name"
    docker::showImagesByPrefix $IMAGE
    docker::createImageAndPushToDockerHub $IMAGE $SNAPSHOT $TAG $DIR
  fi

  kubectl::apply $CONFIGURATION_FILE
  kubectl::waitForDeployment $DEPLOYMENT_SERVER_NAME
  kubectl::waitForDeployment $DEPLOYMENT_CLIENT_NAME && sleep 10
  kubectl::showDeployments -l "poc=$POC_LABEL_VALUE"
  kubectl::showReplicaSets -l "poc=$POC_LABEL_VALUE"
  kubectl::showPods -l "poc=$POC_LABEL_VALUE"
  kubectl::showServices -l "poc=$POC_LABEL_VALUE"
  kubectl::showEndpointsByService $SERVICE_NAME

  print_info "Extract node port from service"
  NODE_PORT=$(kubectl::getNodePortByService ${SERVICE_NAME} http-server)
  checkInteractiveMode

  print_info "Check that the port has been enabled on all nodes"
  NODE_ADDRESSES=$(kubectl::getNodeAddresses)
  for NODE_ADDRESS in ${NODE_ADDRESSES[@]}
  do
    executeCurl http://$NODE_ADDRESS:$NODE_PORT/echo
    if [ $? -ne 0 ]
    then
      print_error "Http server from $NODE_ADDRESS:$NODE_PORT is not available"
      SERVER_AVAILABLE=false
    fi
    checkInteractiveMode
  done

  checkCleanupMode
  print_done "Poc completed successfully"
  exit 0
}

main $@
