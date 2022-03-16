#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../utils/docker-utils.src"
source "${DIR}/../../../utils/microservices-utils.src"

#############
# VARIABLES #
#############

IMAGE_PREFIX="poc-alpine-java"
IMAGE="$IMAGE_PREFIX:1.0"

CONTAINER_PREFIX="poc_alpine_java"
CONTAINER1_NAME="${CONTAINER_PREFIX}_1"

BACKUP_DIRECTORY="${DIR}/backups"
FILE_TAR="${BACKUP_DIRECTORY}/poc-alpine-java-1.0.tar"

#############
# FUNCTIONS #
#############

function initialize() {
  print_info "Preparing poc environment..."
  setTerminalSignals
  cleanup
  print_debug "Creating backup directory..."
  if [ ! -d ${BACKUP_DIRECTORY} ]; then
    xtrace on
    mkdir ${BACKUP_DIRECTORY}
    xtrace off
  fi
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
  docker_utils::removeImages $IMAGE
  xtrace on
  rm -rf ${BACKUP_DIRECTORY}
  xtrace off
}

function executeContainer {
  print_info "Run container..."
  xtrace on
  docker run \
    --rm \
    --name ${CONTAINER1_NAME} \
    ${IMAGE}

  xtrace off
}

function main() {
  print_debug "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  print_info "Filter images by name"
  docker_utils::showImagesByPrefix $IMAGE_PREFIX
  docker_utils::createImageFromDockerfile $IMAGE $DIR

  print_info "Filter images by name"
  docker_utils::showImagesByPrefix $IMAGE_PREFIX

  executeContainer
  checkInteractiveMode

  print_info "Save image to tar file"
  docker_utils::saveImage $FILE_TAR $IMAGE

  docker_utils::removeImages $IMAGE
  print_info "Filter images by name"
  docker_utils::showImagesByPrefix $IMAGE_PREFIX

  print_info "Load image from tar file"
  docker_utils::loadImage $FILE_TAR

  print_info "Filter images by name"
  docker_utils::showImagesByPrefix $IMAGE_PREFIX

  executeContainer
  checkCleanupMode
  print_done "Poc completed successfully "
  exit 0
}

#############
# EXECUTION #
#############

main $@
