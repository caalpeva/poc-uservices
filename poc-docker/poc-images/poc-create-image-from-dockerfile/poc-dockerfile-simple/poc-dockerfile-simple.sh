#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../../utils/docker.src"
source "${DIR}/../../../../utils/uservices.src"

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
  containers=($(docker::getAllContainerIdsByPrefix ${CONTAINER_PREFIX}))
  docker::removeContainers ${containers[*]}
  docker::removeImages $IMAGE
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
  docker::createImageFromDockerfile $IMAGE $DIR

  docker::getImages
  print_box "DANGLING IMAGES" \
    "" \
    " - The images that appear with labels <none>:<none> when executing the docker images command are dangling images." \
    " - These images should be deleted to free up space because they will no longer be used."
  checkInteractiveMode

  docker::getImages "-a"
  print_box "INTERMEDIATE IMAGES" \
    "" \
    " - The images that appear with labels <none>:<none> when executing the docker images -a command are intermediate images." \
    " - Intermediate images are generated every time a new image is created from a dockerfile." \
    " - These images can only be deleted when the image on which they depend is eliminated."
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
