#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/network-utils.src"
source "${DIR}/../../utils/docker.src"
source "${DIR}/../../../utils/microservices-utils.src"

#############
# VARIABLES #
#############

IMAGE="alpine"
TAG="my-snapshot"

CONTAINER_PREFIX="poc_alpine"
CONTAINER1_NAME="${CONTAINER_PREFIX}_1"

REGISTRY_URL="$(getFirstLocalIp):5000"

BACKUP_DIRECTORY="${DIR}/backups"
DOCKER_SERVICE_CONFIG_FILE="/lib/systemd/system/docker.service"
DOCKER_SERVICE_CONFIG_FILE_BACKUP=$BACKUP_DIRECTORY/docker.service

#############
# FUNCTIONS #
#############

function initialize() {
  print_info "Preparing poc environment..."
  setTerminalSignals
  cleanup

  print_debug "Copying backup..."
  if [ ! -d ${BACKUP_DIRECTORY} ]; then
    xtrace on
    mkdir ${BACKUP_DIRECTORY}
    xtrace off
  fi

  xtrace on
  cp $DOCKER_SERVICE_CONFIG_FILE $DOCKER_SERVICE_CONFIG_FILE_BACKUP
  xtrace off
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
  docker::removeImages "$REGISTRY_URL/$IMAGE:$TAG"
  copyDefaultConfigFile
  restartDocker
}

function enableInsecureModeForIp() {
  print_info "Enable insecure mode to IP access"
  print_debug "Add --insecure-registry option to ExecStart param in $DOCKER_SERVICE_CONFIG_FILE file"
  xtrace on
  cat $DOCKER_SERVICE_CONFIG_FILE | grep ExecStart
  xtrace off

  LINE=`cat $DOCKER_SERVICE_CONFIG_FILE | grep ExecStart`
  LINE_NUMBER=`cat $DOCKER_SERVICE_CONFIG_FILE  | grep -n ExecStart | grep -Eo '^[^:]+'`

  xtrace on
  sudo sed -i "${LINE_NUMBER} s/^/#/" $DOCKER_SERVICE_CONFIG_FILE
  sudo sed -i "${LINE_NUMBER} a ${LINE} --insecure-registry $REGISTRY_URL" $DOCKER_SERVICE_CONFIG_FILE
  cat $DOCKER_SERVICE_CONFIG_FILE | grep ExecStart
  xtrace off
  checkInteractiveMode
}

function restartDocker() {
  print_info "Restart docker"
  xtrace on
  sudo systemctl daemon-reload
  sudo systemctl restart docker
  xtrace off
}

function copyDefaultConfigFile() {
  print_info "Copy default configuration file"
  xtrace on
  sudo cp  $DOCKER_SERVICE_CONFIG_FILE_BACKUP $DOCKER_SERVICE_CONFIG_FILE
  xtrace off
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

  print_box "ALTERNATE REGISTRY OF IMAGES ON INSECURE MODE" \
    "" \
    " - Modify the configuration file $DOCKER_SERVICE_CONFIG_FILE to enable insecure mode." \
    " - Restart docker service."
  checkInteractiveMode

  print_info "Execute registry container"
  executeRegistryContainer

  print_info "Check containers status again..."
  docker::showContainersByPrefix ${CONTAINER_PREFIX}

  print_info "Filter images by name"
  docker::showImagesByPrefix $IMAGE

  docker::pullImage "$IMAGE:latest"

  print_info "Retag image for local registry"
  docker::tagImage "$IMAGE:latest" "$REGISTRY_URL/$IMAGE:$TAG"

  print_info "Filter images by name"
  docker::showImagesByPrefix $IMAGE

  print_info "Check that push image to local registry fails"
  docker::pushImage "$REGISTRY_URL/$IMAGE:$TAG"

  print_info "Stop container"
  docker::stopContainers ${CONTAINER1_NAME}
  checkInteractiveMode

  print_info "Check containers status again..."
  docker::showContainersByPrefix ${CONTAINER_PREFIX}

  enableInsecureModeForIp
  restartDocker
  checkInteractiveMode

  print_info "Start container"
  docker::startContainers ${CONTAINER1_NAME}
  checkInteractiveMode

  print_info "Check containers status again..."
  docker::showContainersByPrefix ${CONTAINER_PREFIX}

  print_info "Check that push image to local registry works"
  docker::pushImage "$REGISTRY_URL/$IMAGE:$TAG"

  checkCleanupMode
  print_done "Poc completed successfully "
  exit 0
}

#############
# EXECUTION #
#############

main $@
