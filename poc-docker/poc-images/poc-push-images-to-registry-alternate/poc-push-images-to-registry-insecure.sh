#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../utils/docker-utils.src"
source "${DIR}/../../../utils/microservices-utils.src"

#############
# VARIABLES #
#############

IMAGE="poc-ubuntu-curl"
SNAPSHOT="1.0-snapshot"
TAG="1.0"

CONTAINER_PREFIX="poc_ubuntu_curl"
CONTAINER1_NAME="${CONTAINER_PREFIX}_1"

REGISTRY_URL="localhost:5000"

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
  docker_utils::removeImages "$IMAGE:$SNAPSHOT" "$REGISTRY_URL/$IMAGE:$TAG"
}

function executeRegistryContainer() {
  xtrace on
  docker run -d \
    --restart always \
    --name ${CONTAINER1_NAME} \
    -p 5000:5000 \
    -v $PWD/data/:/var/lib/registry \
    registry:2
  xtrace off
}

function main() {
  print_debug "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  print_info "Execute registry container"
  executeRegistryContainer

  print_info "Check containers status again..."
  docker_utils::showContainersByPrefix ${CONTAINER_PREFIX}

  print_info "Filter images by name"
  docker_utils::showImagesByPrefix $IMAGE
  docker_utils::createImageFromDockerfile "$IMAGE:$SNAPSHOT" $DIR

  print_info "Filter images by name"
  docker_utils::showImagesByPrefix $IMAGE

  print_info "Retag image for local registry"
  docker_utils::tagImage "$IMAGE:$SNAPSHOT" "$REGISTRY_URL/$IMAGE:$TAG"

  print_info "Filter images by name"
  docker_utils::showImagesByPrefix $IMAGE

  print_info "Push image to local registry"
  docker_utils::pushImage "$REGISTRY_URL/$IMAGE:$TAG"

  docker_utils::removeImages "$IMAGE:$SNAPSHOT" "$REGISTRY_URL/$IMAGE:$TAG"

  print_info "Filter images by name"
  docker_utils::showImagesByPrefix $IMAGE

  print_info "Pull image from local registry"
  docker_utils::pullImage "$REGISTRY_URL/$IMAGE:$TAG"

  print_info "Filter images by name"
  docker_utils::showImagesByPrefix $IMAGE

  checkCleanupMode
  print_done "Poc completed successfully "
  exit 0
}

#############
# EXECUTION #
#############

main $@
