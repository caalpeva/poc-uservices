#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../utils/docker.src"
source "${DIR}/../../../utils/uservices.src"

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
  containers=($(docker::getAllContainerIdsByPrefix ${CONTAINER_PREFIX}))
  docker::removeContainers ${containers[*]}
  docker::removeImages "$IMAGE:$SNAPSHOT" "$REGISTRY_URL/$IMAGE:$TAG"
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
  docker::showContainersByPrefix ${CONTAINER_PREFIX}

  print_info "Filter images by name"
  docker::showImagesByPrefix $IMAGE
  docker::createImageFromDockerfile "$IMAGE:$SNAPSHOT" $DIR

  print_info "Filter images by name"
  docker::showImagesByPrefix $IMAGE

  print_info "Retag image for local registry"
  docker::tagImage "$IMAGE:$SNAPSHOT" "$REGISTRY_URL/$IMAGE:$TAG"

  print_info "Filter images by name"
  docker::showImagesByPrefix $IMAGE

  print_info "Push image to local registry"
  docker::pushImage "$REGISTRY_URL/$IMAGE:$TAG"

  docker::removeImages "$IMAGE:$SNAPSHOT" "$REGISTRY_URL/$IMAGE:$TAG"

  print_info "Filter images by name"
  docker::showImagesByPrefix $IMAGE

  print_info "Pull image from local registry"
  docker::pullImage "$REGISTRY_URL/$IMAGE:$TAG"

  print_info "Filter images by name"
  docker::showImagesByPrefix $IMAGE

  checkCleanupMode
  print_done "Poc completed successfully "
  exit 0
}

#############
# EXECUTION #
#############

main $@
