#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../../../dependencies/downloads/poc-bash-master/includes/progress-bar-utils.src"
source "${DIR}/../../../../utils/microservices-utils.src"
source "${DIR}/../../../utils/docker.src"
source "${DIR}/../../../utils/docker-compose.src"

GITLAB_DOMAIN="gitlab.example.com"
CONTAINER_GITLAB="poc_machine_server_git"

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
}

function main {
  print_info "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  print_info "To execute this script successfully, it is necessary to manually execute the steps indicated in the readme.md file."
  print_debug "Create the corresponding job entries in jenkins."
  print_debug "Create repository and user in gitlab."
  checkInteractiveMode

  print_info "Check /etc/hosts file"
  evalCommand "cat /etc/hosts | grep -i $GITLAB_DOMAIN"
    if [ $? -ne 0  ]; then
    xtrace on
    sudo echo "127.0.0.1  $GITLAB_DOMAIN" >> /etc/hosts
    xtrace off
  fi

  print_info "Add application code to gitlab"
  xtrace on
  cd app
  git init
  git remote add origin http://$GITLAB_DOMAIN/poc/poc-app-maven-simple.git
  git add .
  git commit -m "Initial commit"
  git push -u origin master
  cd -
  xtrace off
  checkInteractiveMode

  print_info "Create gitlab hook to jenkins job"
  print_debug "Find repository directory"
  GIT_REPOSITORY_ROOT_DIR="/var/opt/gitlab/git-data/repositories/@hashed"
  DIRECTORY=$(docker::execContainerAsRootDos $CONTAINER_GITLAB find $GIT_REPOSITORY_ROOT_DIR -type d -name "*.git" | grep -v wiki.git)
  echo "Directory---> $DIRECTORY"
  checkInteractiveMode

  print_debug "Create custom_hooks directory"
  docker::execContainerAsRootDos $CONTAINER_GITLAB mkdir -p $DIRECTORY/custom_hooks
  checkInteractiveMode

  print_debug "Copy postreceive script to custom_hooks directory"
  docker::copyFiles hooks/post-receive $CONTAINER_GITLAB:$DIRECTORY/custom_hooks/post-receive

  print_debug "Grant execution permissions to the script"
  docker::execContainerAsRootDos $CONTAINER_GITLAB "chmod +x $DIRECTORY/custom_hooks/post-receive"
  checkInteractiveMode

  print_debug "Change script ownership to git user"
  docker::execContainerAsRootDos $CONTAINER_GITLAB "chown git:git $DIRECTORY/custom_hooks/ -R"
  checkInteractiveMode

  print_info "Check that the gitlab hook works satisfactorily."
  print_debug "Make any changes to the app and push to gitlab."
  print_debug "Check that the execution of the job is triggered from gitlab."
  checkInteractiveMode


  checkCleanupMode
  print_done "Poc completed successfully "
  exit 0
}

main $@
