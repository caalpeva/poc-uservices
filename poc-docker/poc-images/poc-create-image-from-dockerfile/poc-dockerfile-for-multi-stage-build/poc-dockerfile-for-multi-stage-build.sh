#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../../utils/docker-utils.src"
source "${DIR}/../../../../utils/microservices-utils.src"

#############
# VARIABLES #
#############

IMAGE="poc-app-maven-basic:1.0"
IMAGE_BUILDER="poc-maven-builder:1.0"

CONTAINER_PREFIX="poc_app_maven_basic"
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
  containers=($(docker_utils::getAllContainerIdsByPrefix ${CONTAINER_PREFIX}))
  docker_utils::removeContainers ${containers[*]}
  docker_utils::removeImages $IMAGE $IMAGE_BUILDER
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

  docker_utils::getImages
  docker_utils::createBuilderImageFromDockerfile $IMAGE_BUILDER $DIR
  docker_utils::createImageFromDockerfile $IMAGE $DIR

  docker_utils::getImages
  executeContainer

  checkCleanupMode
  print_done "Poc completed successfully "
  exit 0
}

#############
# EXECUTION #
#############

main $@
