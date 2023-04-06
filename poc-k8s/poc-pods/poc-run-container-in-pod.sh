#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../utils/uservices-utils.src"
source "${DIR}/../../poc-docker/utils/docker.src"
source "${DIR}/../utils/kubectl.src"

CONFIGURATION_FILE_POD=${DIR}/config/pod.yaml
POC_LABEL_VALUE="poc-pod-environment"
POD_NAME=$POC_LABEL_VALUE

IMAGE="poc-golang-loop-message"
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
}

function main {
  print_info "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  kubectl::showNodes

  kubectl::apply $CONFIGURATION_FILE_POD
  kubectl::waitForPodsByLabel -l "poc=$POC_LABEL_VALUE"
  kubectl::showPods

  print_info "Wait for a few seconds to show logs..."
  sleep 5
  kubectl::showLogs $POD_NAME

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
