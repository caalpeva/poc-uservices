#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/progress-bar-utils.src"
source "${DIR}/../../../utils/microservices-utils.src"
source "${DIR}/../../../poc-docker/utils/docker.src"
source "${DIR}/../../utils/kubectl.src"

CONFIGURATION_FILE_POD=${DIR}/pod.yaml
POD_NAME="poc-probe-liveness"

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

  print_box "LIVENESS PROBES" \
    "" \
    " - The kubelet uses liveness probes to know when to restart a container." \
    "   For example, liveness probes could catch a deadlock, where an application is running," \
    "   but unable to make progress. Restarting a container in such a state can help to make" \
    "   the application more available despite bugs."
  checkInteractiveMode

  kubectl::showNodes

  kubectl::apply $CONFIGURATION_FILE_POD
  kubectl::waitForReadyPod $POD_NAME
  kubectl::showPods

  print_info "Wait a while for kubelet to use liveness probes..."
  kubectl::showLivenessProbe $POD_NAME
  kubectl::waitForPodRestarted $POD_NAME &
  PID=$!
  showProgressBar $PID
  wait $PID

  kubectl::showPods
  print_debug "Note that when liveness probe fails the pod is restarted"

  checkCleanupMode
  print_done "Poc completed successfully"
  exit 0
}

main $@
