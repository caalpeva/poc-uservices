#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../utils/docker-utils.src"
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
  containers=($(docker_utils::getAllContainerIdsByPrefix ${CONTAINER_PREFIX}))
  docker_utils::removeContainers ${containers[*]}
  docker_utils::removeImages "$IMAGE:$TAG" "$IMAGE:$SNAPSHOT"
}

function dockerLogin() {
  read -p "Username: " DOCKER_USERNAME
  xtrace on
  docker login --username $DOCKER_USERNAME
  xtrace off
  checkInteractiveMode
}

function pushImage() {
  xtrace on
  docker push $1
  xtrace off
  checkInteractiveMode
}

function tagImage() {
  local localImage=$1
  local newLocalImage=$2

  xtrace on
  docker tag $localImage $newLocalImage
  xtrace off
  checkInteractiveMode
}

function main() {
  print_debug "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  print_info "Filter images by name"
  docker_utils::showImagesByPrefix $IMAGE
  docker_utils::createImageFromDockerfile "$IMAGE:$SNAPSHOT" $DIR

  print_info "Filter images by name"
  docker_utils::showImagesByPrefix $IMAGE

  print_info "Login with your Docker ID to push images to Docker Hub"
  dockerLogin

  print_info "Retag image for Docker Hub with username"
  tagImage "$IMAGE:$SNAPSHOT" "$DOCKER_USERNAME/$IMAGE:$TAG"

  print_info "Filter images by name"
  docker_utils::showImagesByPrefix $IMAGE

  print_info "Push image to Docker Hub"
  pushImage "$DOCKER_USERNAME/$IMAGE:$TAG"

  checkCleanupMode
  print_done "Poc completed successfully "
  exit 0
}

#############
# EXECUTION #
#############

main $@
