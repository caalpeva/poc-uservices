#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../utils/docker.src"
source "${DIR}/../../../utils/microservices-utils.src"

#############
# VARIABLES #
#############

IMAGE="poc-ubuntu-utils"
SNAPSHOT="1.0-snapshot"
TAG="1.0"

CONTAINER_PREFIX="poc_ubuntu_utils"
CONTAINER1_NAME="${CONTAINER_PREFIX}_1"

DOCKER_USERNAME="NONE"

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
  docker::removeImages "$IMAGE:$TAG" "$IMAGE:$SNAPSHOT"
}

function dockerLogin() {
  read -p "Username: " DOCKER_USERNAME
  xtrace on
  docker login --username $DOCKER_USERNAME
  xtrace off
  checkInteractiveMode
}

function main() {
  print_debug "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  print_info "Filter images by name"
  docker::showImagesByPrefix $IMAGE
  docker::createImageFromDockerfile "$IMAGE:$SNAPSHOT" $DIR

  print_info "Filter images by name"
  docker::showImagesByPrefix $IMAGE

  print_info "Login with your Docker ID to push images to Docker Hub"
  dockerLogin

  print_info "Retag image for Docker Hub with username"
  docker::tagImage "$IMAGE:$SNAPSHOT" "$DOCKER_USERNAME/$IMAGE:$TAG"

  print_info "Filter images by name"
  docker::showImagesByPrefix $IMAGE

  print_info "Push image to Docker Hub"
  docker::pushImage "$DOCKER_USERNAME/$IMAGE:$TAG"

  checkCleanupMode
  print_done "Poc completed successfully "
  exit 0
}

#############
# EXECUTION #
#############

main $@
