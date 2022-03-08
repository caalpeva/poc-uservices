#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/progress-bar-utils.src"
source "${DIR}/../../../utils/microservices-utils.src"
source "${DIR}/../../utils/docker-utils.src"

IMAGE_PREFIX="poc-centos-exit-code"
IMAGE_EXIT_SUCCESS="$IMAGE_PREFIX:success"
IMAGE_EXIT_FAILURE="$IMAGE_PREFIX:failure"

CONTAINER_PREFIX="poc_centos"
CONTAINER1_NAME="${CONTAINER_PREFIX}_1"
CONTAINER2_NAME="${CONTAINER_PREFIX}_2"
CONTAINER3_NAME="${CONTAINER_PREFIX}_3"
CONTAINER4_NAME="${CONTAINER_PREFIX}_4"
CONTAINER5_NAME="${CONTAINER_PREFIX}_5"
CONTAINER6_NAME="${CONTAINER_PREFIX}_6"

MAX_RETRIES=2

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
  containers=($(docker_utils::getAllContainerIdsByPrefix ${CONTAINER_PREFIX}))
  docker_utils::removeContainers ${containers[*]}
  docker_utils::removeImages $IMAGE_EXIT_SUCCESS $IMAGE_EXIT_FAILURE
}

function checkContainerStatus {
  local container=$1
  docker_utils::showLogs $container
  echo "Status: $(docker_utils::getContainerStatus $container)"
  echo "RestartCount: $(docker_utils::getRestartCountFromContainer $container)"
  checkInteractiveMode
}

function startContainers {
  print_info "Start containers..."
  containers=$(docker_utils::getExitedContainerIdsByPrefix ${CONTAINER_PREFIX})
  for containerId in ${containers}
  do
    docker_utils::startContainers ${containerId}
  done
}

function stopContainers {
  print_info "Stop containers..."
  containers=$(docker_utils::getRunningContainerIdsByPrefix ${CONTAINER_PREFIX})

  for containerId in ${containers}
  do
    docker_utils::stopContainers ${containerId}
  done
}

function restartDocker() {
  print_info "Restart docker"
  xtrace on
  sudo systemctl restart docker
  xtrace off
}

function executeContainers {
  print_info "Execute containers..."
  xtrace on
  docker run -dit \
    --name ${CONTAINER1_NAME} \
    --restart no \
    ${IMAGE_EXIT_SUCCESS}

  docker run -dit \
    --name ${CONTAINER2_NAME} \
    --restart always \
    ${IMAGE_EXIT_SUCCESS}

  docker run -dit \
    --name ${CONTAINER3_NAME} \
    --restart unless-stopped \
    ${IMAGE_EXIT_SUCCESS}

  docker run -dit \
    --name ${CONTAINER4_NAME} \
    --restart on-failure \
    ${IMAGE_EXIT_SUCCESS}

  docker run -dit \
    --name ${CONTAINER5_NAME} \
    --restart on-failure:${MAX_RETRIES} \
    ${IMAGE_EXIT_FAILURE}

  docker run -dit \
    --name ${CONTAINER6_NAME} \
    --restart on-failure \
    ${IMAGE_EXIT_FAILURE}

  xtrace off
}

function main {
  print_info "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  print_box "RESTART POLICY" \
    "" \
    " - no: Do not automatically restart the container. (the default)" \
    " - always: Always restart the container if it stops. If it is manually stopped,it is restarted only" \
    "   when Docker daemon restarts or the container itself is manually restarted." \
    " - unless-stopped: Similar to always, except that when the container is manually stopped,"  \
    "   it is not restarted even after Docker daemon restarts." \
    " - on-failure[:max-retries] Restart the container if it exits due to an error, which manifests as" \
    "   a non-zero exit code. Optionally, limit the number of times the Docker daemon attempts to restart" \
    "   the container using the :max-retries option."
  checkInteractiveMode

  print_info "Show images by prefix"
  docker_utils::getImagesByPrefix $IMAGE_PREFIX

  docker_utils::createImageFromDockerfile $IMAGE_EXIT_SUCCESS "--build-arg EXIT_CODE=0" $DIR
  docker_utils::createImageFromDockerfile $IMAGE_EXIT_FAILURE "--build-arg EXIT_CODE=1" $DIR

  print_info "Show images by prefix"
  docker_utils::getImagesByPrefix $IMAGE_PREFIX
  checkInteractiveMode

  executeContainers
  print_info "Check containers status..."
  sleep 5 &
  PID=$!
  showProgressBar $PID
  wait $PID
  docker_utils::showContainersByPrefix ${CONTAINER_PREFIX}

  print_info "Check container status without restart"
  checkContainerStatus ${CONTAINER1_NAME}

  print_info "Check container status with restart always"
  checkContainerStatus ${CONTAINER2_NAME}

  print_info "Check container status with restart unless-stopped"
  checkContainerStatus ${CONTAINER3_NAME}

  print_info "Check container status with restart on-failure without error (zero exit code)"
  checkContainerStatus ${CONTAINER4_NAME}

  print_info "Check container status with restart on-failure with error (max-retries=$MAX_RETRIES)"
  checkContainerStatus ${CONTAINER5_NAME}

  print_info "Check container status with restart on-failure with error (without max-retries)"
  checkContainerStatus ${CONTAINER6_NAME}

  stopContainers
  print_info "Check containers status after stopping..."
  docker_utils::showContainersByPrefix ${CONTAINER_PREFIX}
  restartDocker

  print_info "Check containers status after docker daemon restarted..."
  sleep 5 &
  PID=$!
  showProgressBar $PID
  wait $PID
  docker_utils::showContainersByPrefix ${CONTAINER_PREFIX}

  print_info "Check container with restart policy always, it was restarted"
  checkContainerStatus ${CONTAINER2_NAME}

  print_info "Check container with restart policy unless-stopped, it was not restarted"
  checkContainerStatus ${CONTAINER3_NAME}

  checkCleanupMode
  print_done "Poc completed successfully "
  exit 0
}

main $@
