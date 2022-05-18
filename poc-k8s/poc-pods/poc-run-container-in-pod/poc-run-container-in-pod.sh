#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../../utils/microservices-utils.src"
source "${DIR}/../../../poc-docker/utils/docker.src"
source "${DIR}/../../utils/kubectl.src"

FLAG_CREATE_AND_PUSH_IMAGE=false

CONFIGURATION_FILE_POD=${DIR}/pod.yaml
POD_NAME="poc-pod-environment"

IMAGE="poc-golang-message-loop"
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
  kubectl::unapply $CONFIGURATION_FILE_POD
  images=($(docker::getImagesWithTags $IMAGE))
  if [ ${#images[@]} -gt 0 ]; then
    docker::removeImages ${images[*]}
  fi
}

function main {
  print_info "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  if [ $FLAG_CREATE_AND_PUSH_IMAGE = true ]; then
    print_info "Filter images by name"
    docker::showImagesByPrefix $IMAGE
    docker::createImageAndPushToDockerHub $IMAGE $SNAPSHOT $TAG $DIR
  fi

  kubectl::apply $CONFIGURATION_FILE_POD
  kubectl::showPodsByDefaultNamespace

  print_info "Show logs..."
  kubectl::showLogsByDefaultNamespace $POD_NAME

  #print_info "Run command in the same running container with tty..."
  #print_debug "Use the shell for example to execute:\n\tprintenv"
  #print_info "-Type exit to exit"
  #kubectl::execUniqueContainerWithTty $POD_NAME "/bin/sh"
  print_info "Check environment variables"
  kubectl::execUniqueContainer $POD_NAME "printenv"

  checkCleanupMode
  print_done "Poc completed successfully"
  exit 0
}

main $@
