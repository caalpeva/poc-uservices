#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../../utils/docker.src"
source "${DIR}/../../../../utils/uservices.src"

#############
# VARIABLES #
#############

IMAGE="poc-app-maven:1.0"
IMAGE_BUILDER="poc-maven-builder:1.0"

CONTAINER_PREFIX="poc_app_maven"
CONTAINER1_NAME="${CONTAINER_PREFIX}_1"

#############
# FUNCTIONS #
#############

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

function cleanup() {
  print_debug "Cleaning environment..."
  containers=($(docker::getAllContainerIdsByPrefix ${CONTAINER_PREFIX}))
  docker::removeContainers ${containers[*]}
  docker::removeImages $IMAGE $IMAGE_BUILDER
}

function executeContainer {
  print_info "Run container..."
  xtrace on
  docker run \
    --name ${CONTAINER1_NAME} \
    ${IMAGE}

  xtrace off
}

function main() {
  print_debug "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  docker::getImages
  docker::createBuilderImageFromDockerfile $IMAGE_BUILDER $DIR
  docker::createImageFromDockerfile $IMAGE $DIR

  docker::getImages
  executeContainer

  checkCleanupMode
  print_done "Poc completed successfully "
  exit 0
}

#############
# EXECUTION #
#############

main $@
