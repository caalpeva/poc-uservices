#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/progress-bar-utils.src"
source "${DIR}/../../utils/microservices-utils.src"
source "${DIR}/../../poc-docker/utils/docker.src"
source "${DIR}/../utils/kubectl.src"

CONFIGFILE_INGRESS_CONTROLLER=${DIR}/components/nginx-ingress-controller.yaml
NAMESPACE=ingress-nginx

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
  kubectl::unapply $CONFIGFILE_INGRESS_CONTROLLER
}

function main {
  print_info "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  print_box "INGRESS CONTROLLER INSTALLATION" \
    "" \
    " - Installs the ingress controller with nginx that manages external access to the services in a cluster."
  checkInteractiveMode

  kubectl::showNodes
  kubectl::apply $CONFIGFILE_INGRESS_CONTROLLER

  print_info "Wait for ingress-controller..."
  print_debug "The first time the ingress controller starts, two Jobs create the SSL Certificate"
  print_debug "used by the admission webhook. This can cause an initial delay of up to two minutes"
  print_debug "until it is possible to create and validate Ingress definitions."
  xtrace on
  kubectl wait --namespace ingress-nginx \
    --for=condition=ready pod \
    -l app.kubernetes.io/component=controller \
    --timeout=120s
  xtrace off
  checkInteractiveMode

  print_info "Check ingress controller version"
  POD_NAME=$(kubectl::getRunningPods -n $NAMESPACE -l app.kubernetes.io/name=ingress-nginx)
  xtrace on
  kubectl exec $POD_NAME -n $NAMESPACE -- /nginx-ingress-controller --version
  xtrace off

  checkCleanupMode
  print_done "Poc completed successfully"
  exit 0
}

main $@
