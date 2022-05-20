#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../../utils/microservices-utils.src"
source "${DIR}/../../../poc-docker/utils/docker.src"
source "${DIR}/../../utils/kubectl.src"

FLAG_CREATE_AND_PUSH_IMAGE=false

CONFIGURATION_FILE=${DIR}/deployment-service-cluster-ip.yaml
DEPLOYMENT_CLIENT_NAME="poc-client"
DEPLOYMENT_SERVER_NAME="poc-server"
SERVICE_NAME="poc-service"
LABEL_NAME="poc-service"

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
  kubectl::showDeployments
  kubectl::showReplicaSets
  kubectl::showPodsByLabel "poc=$LABEL_NAME"
  kubectl::showServices "poc=$LABEL_NAME"
  kubectl::showEndpointsByService $SERVICE_NAME

  print_info "Show logs from client pod..."
  POD_NAME=$(kubectl::getFirstPodNameByLabel "app=$DEPLOYMENT_CLIENT_NAME")
  kubectl::showLogs $POD_NAME

  checkCleanupMode
  print_done "Poc completed successfully"
  exit 0
}

main $@
