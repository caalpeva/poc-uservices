#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../utils/docker-utils.src"
source "${DIR}/../../../utils/microservices-utils.src"

#############
# VARIABLES #
#############

IMAGE="ubuntu-git:1.0"

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
  removeImages $IMAGE
}


function showDockerImageList() {
  local option=${1:-}
  print_info "Show docker images"  
  xtrace on
  docker images $option
  xtrace off
  checkInteractiveMode
}

function createImageFromDockerfile() {
  print_info "Create image from Dockerfile"  
  xtrace on
  docker build -t $1 $2
  xtrace off
  checkInteractiveMode
}

function removeImages() {
  print_info "Remove images: $@"
  xtrace on
  docker rmi $@
  xtrace off
  checkInteractiveMode
}

function main() {
  print_debug "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  showDockerImageList
  createImageFromDockerfile $IMAGE $DIR

  showDockerImageList
  echo -e "The images that appear with labels <none>:<none> when executing the docker images command are dangling images."
  echo -e "These images should be deleted to free up space because they will no longer be used."
  checkInteractiveMode

  showDockerImageList "-a"
  echo -e "The images that appear with labels <none>:<none> when executing the docker images -a command are intermediate images."
  echo -e "Intermediate images are generated every time a new image is created from a dockerfile."
  echo -e "These images can only be deleted when the image on which they depend is eliminated."
  checkInteractiveMode

  checkCleanupMode
  print_done "Poc completed successfully "
  exit 0
}

#############
# EXECUTION #
#############

main $@
