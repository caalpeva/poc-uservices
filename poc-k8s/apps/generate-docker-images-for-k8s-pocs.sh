#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../utils/microservices-utils.src"
source "${DIR}/../../poc-docker/utils/docker.src"
source "${DIR}/../utils/kubectl.src"

SNAPSHOT="1.0-snapshot"
TAG="1.0"

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

function cleanup {
  print_debug "Cleaning environment..."
  patterns=($(listDirectoryNames))
  for pattern in ${patterns[@]}
  do
    images=($(docker::getImagesWithTags $pattern))
    if [ ${#images[@]} -gt 0 ]; then
      docker::removeImages ${images[*]}
    fi
  done
}

function listDirectoryNames() {
  xtrace on
  ls -d ${DIR}/*/ | xargs -l basename
  xtrace off
}

function main {
  print_info "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  print_box "GENERATE IMAGES DOCKER FOR K8S POCS" \
    "" \
    "This script generates and pushes docker images for use in proofs of concept about kubernetes."
  checkInteractiveMode

  print_info "Login with your Docker ID to push images to Docker Hub"
  DOCKER_USERNAME=$(docker::loginPrompt)
  docker::login ${DOCKER_USERNAME:="none"}

  print_info "List applications to generate images"
  images=($(listDirectoryNames))
  printf '%s\n' ${images[@]}
  count=${#images[*]}

  declare -i index=0
  for image in ${images[@]}
  do
      index+=1
      print_info "Processing application ($index/$count): $image"
      checkInteractiveMode

      print_info "Filter images by name"
      docker::showImagesByPrefix $image
      docker::createImageAndPushToDockerHub $image $SNAPSHOT $TAG $DOCKER_USERNAME ${DIR}/$image
  done

  checkCleanupMode
  print_done "Execution completed successfully"
  exit 0
}

main $@
