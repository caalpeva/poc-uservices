#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../../utils/uservices-utils.src"
source "${DIR}/../../../poc-k8s/utils/kubectl.src"
source "${DIR}/../../utils/helm.src"

#############
# VARIABLES #
#############

CHARTS_DIRECTORY="${DIR}/charts"

NAMESPACE="poc-charts"

CHART_NAME="nginx"
CHART_RELEASE="poc-$CHART_NAME"

LOCAL_PORT=8080

#############
# FUNCTIONS #
#############

function initialize() {
  print_info "Preparing poc environment..."
  setTerminalSignals
  check_mandatory_command_installed tree
  cleanup
}

function handleTermSignal() {
  xtrace off
  print_warn "Handling termination signal..."
  cleanup
  exit 1
}

function cleanup() {
  print_debug "Cleaning environment..."
  if [ -n "$PORT_FORWARD_PID" ]; then
    print_info "Kill the execution of the port-forward command"
    evalCommand kill -9 $PORT_FORWARD_PID
  fi
  helm::uninstallChart $CHART_RELEASE --namespace $NAMESPACE
  kubectl delete ns $NAMESPACE
}

function main() {
  print_debug "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  print_box "INSTALL CHART WITH NAME GENERATED" \
    "" \
    " - Proof of concept about chart installation with name generated"
  checkInteractiveMode

  kubectl::showNodes

  print_info "Before installing the chart, find out what values can be set."
  helm::showDefaultLimitedChartValues 25 "${CHARTS_DIRECTORY}/$CHART_NAME"

  print_info "Install chart"
  CHART_RELEASE=$(helm::getReleaseFromChartInstallation "${CHARTS_DIRECTORY}/$CHART_NAME" \
    --namespace $NAMESPACE --create-namespace \
    --generate-name #--name-template="nginx-{{randAlpha 3 | lower}}{{randNumeric 5}}"
    )

  print_info "List chart releases"
  helm::showChartReleasesByPrefix $CHART_RELEASE -n $NAMESPACE
  helm::getReleaseStatus $CHART_RELEASE -n $NAMESPACE
  helm::getCustomValues $CHART_RELEASE -n $NAMESPACE

  LABELS="app.kubernetes.io/name=$CHART_NAME,app.kubernetes.io/instance=$CHART_RELEASE"
  SERVICE_NAME=$CHART_RELEASE

  kubectl::showDeployments -n $NAMESPACE -l $LABELS
  kubectl::showReplicaSets -n $NAMESPACE -l $LABELS
  kubectl::showPods -n $NAMESPACE -l $LABELS
  kubectl::showServices -n $NAMESPACE -l $LABELS
  kubectl::showEndpointsByService $SERVICE_NAME -n $NAMESPACE

  print_info "Extract port from service"
  SERVICE_PORT=$(kubectl::getPortByService ${SERVICE_NAME} http -n $NAMESPACE)
  checkInteractiveMode

  print_info "Forward local port to service port"
  evalCommand kubectl --namespace poc-charts port-forward service/${SERVICE_NAME} --address 0.0.0.0 ${LOCAL_PORT}:${SERVICE_PORT} "&"
  PORT_FORWARD_PID=$!
  checkInteractiveMode

  sleep 3
  SERVER_AVAILABLE=true
  print_info "Visit http://localhost:${LOCAL_PORT} to use this application"
  print_debug "Make request from local port..."
  executeCurl http://localhost:$LOCAL_PORT
  if [ $? -ne 0 ]
  then
    print_error "Http server is not available"
    SERVER_AVAILABLE=false
  fi
  checkInteractiveMode

  checkCleanupMode
  if [ $SERVER_AVAILABLE = false ]; then
    print_error "Poc completed with failure"
    exit 1
  fi

  print_done "Poc completed successfully"
  exit 0
}

#############
# EXECUTION #
#############

main $@
