#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../../../dependencies/downloads/poc-bash-master/includes/progress-bar-utils.src"
source "${DIR}/../../../../utils/uservices.src"
source "${DIR}/../../../utils/docker.src"
source "${DIR}/../../../utils/docker-compose.src"

PROJECT_NAME="poc_jenkins"
NETWORK_NAME="${PROJECT_NAME}_network"
IMAGE="poc-centos-server-ssh:keys"

CONTAINER_JENKINS="poc_server_jenkins"
CONTAINER_SSH="poc_server_ssh"

JENKINS_DIRECTORY="${DIR}/mount/jenkins"
GITLAB_DIRECTORY="${DIR}/mount/gitlab"
DOCKER_REGISTRY_DIRECTORY="${DIR}/mount/docker-registry"
JOBS_DIRECTORY="${DIR}/jobs"
TMP_DIRECTORY="${DIR}/tmp"

SSH_SERVER_USER="jenkins"
SSH_SERVER_PASSWORD="1234"

function initialize() {
  print_info "Preparing poc environment..."
  setTerminalSignals
  cleanup
  print_debug "Creating data directory..."
  if [ ! -d ${JENKINS_DIRECTORY} ]; then
    xtrace on
    mkdir -p ${JENKINS_DIRECTORY}
    xtrace off
  fi
  if [ ! -d ${GITLAB_DIRECTORY} ]; then
    xtrace on
    mkdir -p ${GITLAB_DIRECTORY}
    xtrace off
  fi
  if [ ! -d ${DOCKER_REGISTRY_DIRECTORY} ]; then
    xtrace on
    mkdir -p ${DOCKER_REGISTRY_DIRECTORY}
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
}

function createDslScriptForParentJob {
  print_info "Create DSL script for parent job"
  xtrace on
  cat ${JOBS_DIRECTORY}/* > ${JOBS_DIRECTORY}/job-parent.dsl
  xtrace off
  checkInteractiveMode
}

function main {
  print_info "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  print_box "JENKINS" \
    "" \
    " Jenkins is an automation tool for tasks that belong to the software development workflow." \
    " - First run the poc-compose-jenkins-generate-ssh-keys.sh script to generate the ssh keys." \
    " - After deploying the microservices, run the poc-compose-jenkins-configure-gitlab-hooks.sh " \
    "   to add data to a repository and configure the hooks."
  checkInteractiveMode

  if [ ! -d ${TMP_DIRECTORY} ]; then
    print_error "SSH keys not found."
    exit 1
  fi

  createDslScriptForParentJob

  docker::createImageFromDockerfile $IMAGE \
    "--build-arg NEWUSER=$SSH_SERVER_USER" \
    "--build-arg NEWUSER_PASSWORD=$SSH_SERVER_PASSWORD" \
    "--file dockerfile-server-ssh-keys" $DIR
  checkInteractiveMode

  print_info "Execute docker-compose"
  docker_compose::upWithProjectName $PROJECT_NAME --build

  print_info "Check containers status..."
  docker_compose::psWithProjectName $PROJECT_NAME

  print_info "Change owner of docker volume"
  docker::execContainerAsRoot $CONTAINER_JENKINS "chown jenkins /var/run/docker.sock"

  print_info "Get ip address from ssh server container"
  SSH_SERVER_IP=$(docker::getIpAddressFromContainer ${CONTAINER_SSH} "${NETWORK_NAME}")
  echo ${SSH_SERVER_IP}
  checkInteractiveMode

  print_info "Check ssh connection with private key to ssh server container from localhost"
  evalCommand "ssh -i $TMP_DIRECTORY/key -o \"StrictHostKeyChecking no\" $SSH_SERVER_USER@${SSH_SERVER_IP} date"
  if [ $? -ne 0 ]; then
    print_error "Error connecting via ssh."
    exit 1
  fi

  print_info "Check connection of Jenkins container"
  print_debug "Interactive in http://localhost:8080 to manage jenkins jobs"
  print_debug "Create SSH connection from jenkins with ${CONTAINER_SSH}, port 22, user $SSH_SERVER_USER and private key $TMP_DIRECTORY/key"
  checkInteractiveMode

  checkCleanupMode
  print_done "Poc completed successfully "
  exit 0
}

main $@
