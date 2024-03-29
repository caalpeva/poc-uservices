#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../../../dependencies/downloads/poc-bash-master/includes/progress-bar-utils.src"
source "${DIR}/../../../../utils/uservices.src"
source "${DIR}/../../../utils/docker.src"
source "${DIR}/../../../utils/docker-compose.src"

PROJECT_NAME="poc_java_remote_debug"
IMAGE_PREFIX=$PROJECT_NAME
IMAGE="$IMAGE_PREFIX:1.0"

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

  print_info "Add remote JVM debugging configuration from IDE"
  print_debug "localhost and port = 8000"
  checkInteractiveMode
  print_info "Attach $PROJECT_NAME container via docker"
  docker::attachContainer $PROJECT_NAME

  checkCleanupMode
  print_done "Poc completed successfully "
  exit 0
}

main $@
