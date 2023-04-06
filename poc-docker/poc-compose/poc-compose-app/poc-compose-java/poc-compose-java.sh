#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../../../dependencies/downloads/poc-bash-master/includes/progress-bar-utils.src"
source "${DIR}/../../../../utils/uservices.src"
source "${DIR}/../../../utils/docker.src"
source "${DIR}/../../../utils/docker-compose.src"

IMAGE_PREFIX="poc-java-remote-debug"
IMAGE="$IMAGE_PREFIX:1.0"

PROJECT_NAME="poc_java"

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
  docker_compose::downWithProjectName $PROJECT_NAME -v
  docker::removeImages $IMAGE
  print_info "Clean project"
  mvn clean -DpomFile=$DIR
}

function main {
  print_info "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  print_box "JAVA" \
    "" \
    " - Proof of concept about remote debug in Java."
  checkInteractiveMode

  print_info "Build project"
  mvn package -DpomFile=$DIR
  checkInteractiveMode

  print_info "Filter images by name"
  docker::showImagesByPrefix $IMAGE_PREFIX
  docker::createImageFromDockerfile $IMAGE --file dockerfile-java $DIR

  print_info "Execute docker-compose"
  docker_compose::upWithProjectName $PROJECT_NAME

  print_info "Check containers status..."
  docker_compose::psWithProjectName $PROJECT_NAME

  print_info "Check container connections"
  print_debug "Interactive with IDE to create remote debug connection on port 8000 to container"
  print_debug "Attach container via docker attach $PROJECT_NAME"
  checkInteractiveMode

  checkCleanupMode
  print_done "Poc completed successfully "
  exit 0
}

main $@
