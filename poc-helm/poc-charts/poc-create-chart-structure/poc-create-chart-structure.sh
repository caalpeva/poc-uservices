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

TMP_DIRECTORY="${DIR}/tmp"

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
  print_debug "Creating temporal directory..."
  if [ ! -d ${TMP_DIRECTORY} ]; then
    evalCommand mkdir ${TMP_DIRECTORY}
  fi
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
    xtrace on
    kill -9 $PORT_FORWARD_PID
    xtrace off
  fi
  helm::uninstallChart $CHART_RELEASE
  kubectl delete ns $NAMESPACE
  evalCommand rm -rf ${TMP_DIRECTORY}
  xtrace off
}

function main() {
  print_debug "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  print_box "CREATE CHART STRUCTURE" \
    "" \
    " - Proof of concept about creation of a chart directory"
  checkInteractiveMode

  kubectl::showNodes
  helm::createChart "${TMP_DIRECTORY}/$CHART_NAME" #--namespace $NAMESPACE

  print_info "Show the content of the directory created"
  evalCommand tree -a "${TMP_DIRECTORY}/$CHART_NAME"
  checkInteractiveMode

  helm::installChart $CHART_RELEASE "${TMP_DIRECTORY}/$CHART_NAME" \
    --namespace $NAMESPACE --create-namespace

  print_info "Show chart instance"
  helm::showChartReleasesByPrefix $CHART_RELEASE -n $NAMESPACE

  kubectl::showDeployments -n $NAMESPACE -l $LABELS
  kubectl::showReplicaSets -n $NAMESPACE -l $LABELS
  kubectl::showPods -n $NAMESPACE -l $LABELS
  kubectl::showServices -n $NAMESPACE -l $LABELS
  kubectl::showEndpointsByService $SERVICE_NAME -n $NAMESPACE

  print_info "Forward local port to container port"
  POD_NAME=$(kubectl get pods --namespace poc-charts -l "$LABELS" -o jsonpath="{.items[0].metadata.name}")
  CONTAINER_PORT=$(kubectl get pod --namespace poc-charts $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
  evalCommand kubectl --namespace poc-charts port-forward $POD_NAME ${LOCAL_PORT}:$CONTAINER_PORT "&"
  PORT_FORWARD_PID=$!
  checkInteractiveMode

  sleep 3
  SERVER_AVAILABLE=true
  print_info "Visit http://localhost:${LOCAL_PORT} to use this application"
  print_debug "Make requests from local port..."
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
