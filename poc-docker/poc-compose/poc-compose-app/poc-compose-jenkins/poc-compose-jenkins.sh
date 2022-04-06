#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../../../dependencies/downloads/poc-bash-master/includes/progress-bar-utils.src"
source "${DIR}/../../../../utils/microservices-utils.src"
source "${DIR}/../../../utils/docker.src"
source "${DIR}/../../../utils/docker-compose.src"

PROJECT_NAME="poc_jenkins"
NETWORK_NAME="${PROJECT_NAME}_network"
IMAGE="centos-server-ssh-with-keys"

CONTAINER_JENKINS="poc_jenkins"
CONTAINER_SSH="poc_machine_server_ssh"
JENKINS_DIRECTORY="${DIR}/jenkins"
GITLAB_DIRECTORY="${DIR}/gitlab"
DOCKER_REGISTRY_DIRECTORY="${DIR}/docker-registry"
KEYS_DIRECTORY="${DIR}/ssh-keys"

SSH_SERVER_USER="perico"
SSH_SERVER_PASSWORD="1234"

function initialize() {
  print_info "Preparing poc environment..."
  setTerminalSignals
  cleanup
  print_debug "Creating data directory..."
  xtrace on
  if [ ! -d ${JENKINS_DIRECTORY} ]; then
    xtrace on
    mkdir ${JENKINS_DIRECTORY}
    xtrace off
  fi
  xtrace on
  if [ ! -d ${GITLAB_DIRECTORY} ]; then
    xtrace on
    mkdir ${GITLAB_DIRECTORY}
    xtrace off
  fi
  xtrace on
  if [ ! -d ${DOCKER_REGISTRY_DIRECTORY} ]; then
    xtrace on
    mkdir ${DOCKER_REGISTRY_DIRECTORY}
    xtrace off
  fi
  xtrace off
  print_debug "Creating ssh keys directory..."
  if [ ! -d ${KEYS_DIRECTORY} ]; then
    xtrace on
    mkdir ${KEYS_DIRECTORY}
    xtrace off
  fi
}

function handleTermSignal() {
  xtrace off
  print_warn "Handling termination signal..."
  cleanup
  exit 1
}

function cleanup {
  print_debug "Cleaning environment..."
  docker_compose::downWithProjectName $PROJECT_NAME
  docker::removeImages $IMAGE
  xtrace on
  rm -rf ${KEYS_DIRECTORY}
  xtrace off
}

function main {
  print_info "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  print_box "JENKINS" \
    "" \
    " - ."
  checkInteractiveMode

  print_info "Generate ssh keys"
  xtrace on
  ssh-keygen -f ${KEYS_DIRECTORY}/key -m PEM -N ''
  xtrace off
  checkInteractiveMode

  docker::createImageFromDockerfile $IMAGE \
    "--build-arg NEWUSER=$SSH_SERVER_USER" \
    "--build-arg NEWUSER_PASSWORD=$SSH_SERVER_PASSWORD" \
    "--file dockerfile-server-ssh-with-keys" $DIR

  print_info "Execute docker-compose"
  docker_compose::upWithProjectName $PROJECT_NAME

  print_info "Check containers status..."
  docker_compose::psWithProjectName $PROJECT_NAME

  print_info "Change owner of docker volume"
  docker::execContainerAsRoot $CONTAINER_JENKINS "chown jenkins /var/run/docker.sock"

  print_info "Get ip address from ssh server container"
  SSH_SERVER_IP=$(docker::getIpAddressFromContainer ${CONTAINER_SSH} "${NETWORK_NAME}")
  echo ${SSH_SERVER_IP}
  checkInteractiveMode

  print_info "Check ssh connection with private key to ssh server container from localhost"
  evalCommand "ssh -i $KEYS_DIRECTORY/key -o \"StrictHostKeyChecking no\" $SSH_SERVER_USER@${SSH_SERVER_IP} date"
  if [ $? -ne 0 ]; then
    print_error "Error connecting via ssh."
    exit 1
  fi

  print_info "Check connection of Jenkins container"
  print_debug "Interactive in http://localhost:8080 to manage jenkins jobs"
  print_debug "Create SSH connection from jenkins with ${CONTAINER_SSH}, port 22, user $SSH_SERVER_USER and private key $KEYS_DIRECTORY/key"
  checkInteractiveMode

  checkCleanupMode
  print_done "Poc completed successfully "
  exit 0
}

main $@
