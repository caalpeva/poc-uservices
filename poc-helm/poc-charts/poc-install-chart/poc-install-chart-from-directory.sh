#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../../utils/microservices-utils.src"
source "${DIR}/../../../poc-k8s/utils/kubectl.src"
source "${DIR}/../../utils/helm.src"

#############
# VARIABLES #
#############

NAMESPACE="poc-charts"

CHART_NAME="nginx"
CHART_RELEASE="poc-$CHART_NAME"
SERVICE_NAME=$CHART_RELEASE

LABELS="app.kubernetes.io/name=$CHART_NAME,app.kubernetes.io/instance=$CHART_RELEASE"
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
  helm::uninstallChart $CHART_RELEASE
  kubectl delete ns $NAMESPACE
  #evalCommand rm -rf "${DIR}/$CHART_NAME"
}

function main() {
  print_debug "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  print_box "INSTALL CHART FROM DIRECTORY" \
    "" \
    " - Install chart from directory"
  checkInteractiveMode

  kubectl::showNodes
  #helm::createChart "${DIR}/$CHART_NAME" #--namespace $NAMESPACE

  print_info "Show the content of the directory created"
  evalCommand tree -a "${DIR}/$CHART_NAME"
  checkInteractiveMode

  helm::installChart $CHART_RELEASE $CHART_NAME --namespace $NAMESPACE --create-namespace

  print_info "Show chart instance"
  helm::showChartReleasesByPrefix $CHART_RELEASE -n $NAMESPACE

  kubectl::showDeployments -n $NAMESPACE -l $LABELS
  kubectl::showReplicaSets -n $NAMESPACE -l $LABELS
  kubectl::showPods -n $NAMESPACE -l $LABELS
  kubectl::showServices -n $NAMESPACE -l $LABELS
  kubectl::showEndpointsByService $SERVICE_NAME -n $NAMESPACE

  print_info "Extract port from service"
  SERVICE_PORT=$(kubectl::getPortByService $CHART_RELEASE http -n $NAMESPACE)
  checkInteractiveMode

  print_info "Forward local port to service port"
  evalCommand kubectl --namespace $NAMESPACE port-forward service/${SERVICE_NAME} ${LOCAL_PORT}:${SERVICE_PORT} "&"
  PID=$!
  checkInteractiveMode

  sleep 3
  SERVER_AVAILABLE=true
  print_info "Visit http://localhost:${LOCAL_PORT} to use this application"
  print_debug "Make requests from local port..."
  for i in {1..3}
  do
    executeCurl http://localhost:$LOCAL_PORT
    if [ $? -ne 0 ]
    then
      print_error "Http server is not available"
      SERVER_AVAILABLE=false
    fi
  done
  checkInteractiveMode

  print_info "Kill the execution of the port-forward command"
  xtrace on
  kill -9 $PID
  xtrace off
  checkCleanupMode

  if [ $SERVER_AVAILABLE = false ]; then
    print_error "Poc completed with failure"
    exit 1
  fi

  checkCleanupMode
  print_done "Poc completed successfully"
  exit 0
}

#############
# EXECUTION #
#############

main $@
