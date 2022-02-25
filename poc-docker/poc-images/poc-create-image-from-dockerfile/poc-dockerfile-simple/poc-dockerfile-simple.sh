#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../../utils/docker-utils.src"
source "${DIR}/../../../../utils/microservices-utils.src"

#############
# VARIABLES #
#############

IMAGE="poc-ubuntu-git:1.0"

CONTAINER_PREFIX="poc_ubuntu_git"
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
  docker_utils::removeImages $IMAGE
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
  docker_utils::createImageFromDockerfile $IMAGE $DIR

  docker_utils::getImages
  echo -e "### NOTE ###"
  echo -e "The images that appear with labels <none>:<none> when executing the docker images command are dangling images."
  echo -e "These images should be deleted to free up space because they will no longer be used."
  echo -e "############"
  checkInteractiveMode

  docker_utils::getImages "-a"
  echo -e "### NOTE ###"
  echo -e "The images that appear with labels <none>:<none> when executing the docker images -a command are intermediate images."
  echo -e "Intermediate images are generated every time a new image is created from a dockerfile."
  echo -e "These images can only be deleted when the image on which they depend is eliminated."
  echo -e "############"
  checkInteractiveMode

  executeContainer
  checkInteractiveMode

  checkCleanupMode
  print_done "Poc completed successfully "
  exit 0
}

#############
# EXECUTION #
#############

main $@
