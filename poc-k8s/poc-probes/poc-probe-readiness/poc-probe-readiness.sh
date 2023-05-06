#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/progress-bar-utils.src"
source "${DIR}/../../../utils/uservices.src"
source "${DIR}/../../../poc-docker/utils/docker.src"
source "${DIR}/../../utils/kubectl.src"

CONFIG_DIR=${DIR}/config
CONFIGFILE_PODS=${CONFIG_DIR}/pods.yaml
CONFIGFILE_SERVICE=${CONFIG_DIR}/service.yaml
SERVICE_NAME="poc-probe-readiness"
POC_LABEL_VALUE=$SERVICE_NAME

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
  kubectl::unapply $CONFIGFILE_SERVICE $CONFIGFILE_PODS
}

function main {
  print_info "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  print_box "READINESS PROBES" \
    "" \
    " - The kubelet uses readiness probes to know when a container is ready to start accepting traffic." \
    "   A Pod is considered ready when all of its containers are ready." \
    "   One use of this signal is to control which Pods are used as backends for Services." \
    "   When a Pod is not ready, it is removed from Service load balancers."
  checkInteractiveMode

  kubectl::showNodes

  kubectl::apply $CONFIGFILE_PODS $CONFIGFILE_SERVICE
  kubectl::waitForPodsByLabel -l "poc=$POC_LABEL_VALUE"
  kubectl::showPods
  kubectl::showServices -l "poc=$POC_LABEL_VALUE"
  kubectl::showEndpointsByService $SERVICE_NAME

  print_info "Wait a while for kubelet to use readiness probes..."
  kubectl::showReadinessProbe $POD_NAME && sleep 30
  kubectl::showPods

  print_info "Check that when readiness probe fails the pod is not restarted"
  print_debug "The pod will be marked as not ready and its IP will be removed from the service endpoints"
  kubectl::showServices -l "poc=$POC_LABEL_VALUE"
  kubectl::showEndpointsByService $SERVICE_NAME

  checkCleanupMode
  print_done "Poc completed successfully"
  exit 0
}

main $@
