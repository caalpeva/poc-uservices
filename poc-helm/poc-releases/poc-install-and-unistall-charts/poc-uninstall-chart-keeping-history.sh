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
CONFIGURATION_FILE1=${DIR}/config/custom-values.yaml
CONFIGURATION_FILE2=${DIR}/config/custom-values2.yaml

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

  print_box "UNINSTALL CHART KEEPING HISTORY" \
    "" \
    " - Proof of concept about chat uninstallation keeping history"
  checkInteractiveMode

  kubectl::showNodes

  print_info "Before installing the chart, find out what values can be set."
  helm::showDefaultLimitedChartValues 25 "${CHARTS_DIRECTORY}/$CHART_NAME"

  helm::installChartSilently $CHART_RELEASE "${CHARTS_DIRECTORY}/$CHART_NAME" \
    --namespace $NAMESPACE --create-namespace \
    #--wait --timeout 3m30s

  helm::historyChart $CHART_RELEASE --namespace $NAMESPACE
  helm::getCustomValues $CHART_RELEASE -n $NAMESPACE

  kubectl::showDeployments -n $NAMESPACE -l $LABELS
  kubectl::showReplicaSets -n $NAMESPACE -l $LABELS
  kubectl::showPods -n $NAMESPACE -l $LABELS
  kubectl::showServices -n $NAMESPACE -l $LABELS
  kubectl::showEndpointsByService $SERVICE_NAME -n $NAMESPACE

  helm::upgradeChartSilently $CHART_RELEASE "${CHARTS_DIRECTORY}/$CHART_NAME" \
    --namespace $NAMESPACE \
    --version 10.6.3 \
    --values $CONFIGURATION_FILE1

  helm::historyChart $CHART_RELEASE --namespace $NAMESPACE
  helm::getCustomValues $CHART_RELEASE -n $NAMESPACE

  kubectl::showDeployments -n $NAMESPACE -l $LABELS
  kubectl::showReplicaSets -n $NAMESPACE -l $LABELS
  kubectl::showPods -n $NAMESPACE -l $LABELS
  kubectl::showServices -n $NAMESPACE -l $LABELS
  kubectl::showEndpointsByService $SERVICE_NAME -n $NAMESPACE

  print_info "Check chart upgrade"
  print_debug "Note that service type and port has changed to NodePort and 95."
  checkInteractiveMode

  helm::upgradeChartSilently $CHART_RELEASE "${CHARTS_DIRECTORY}/$CHART_NAME" \
    --namespace $NAMESPACE \
    --version 10.6.4 \
    -f $CONFIGURATION_FILE2

  helm::historyChart $CHART_RELEASE --namespace $NAMESPACE
  helm::getCustomValues $CHART_RELEASE -n $NAMESPACE

  kubectl::showDeployments -n $NAMESPACE -l $LABELS
  kubectl::showReplicaSets -n $NAMESPACE -l $LABELS
  kubectl::showPods -n $NAMESPACE -l $LABELS
  kubectl::showServices -n $NAMESPACE -l $LABELS
  kubectl::showEndpointsByService $SERVICE_NAME -n $NAMESPACE

  print_info "Check chart upgrade again"
  print_debug "Note that service type and port has changed to ClusterIP and 99."
  checkInteractiveMode

  helm::uninstallChart $CHART_RELEASE -n $NAMESPACE --keep-history

  print_info "List chart releases after uninstallation keeping history"
  helm::showChartReleasesByPrefix $CHART_RELEASE -n $NAMESPACE
  helm::historyChart $CHART_RELEASE --namespace $NAMESPACE

  print_info "Check chart uninstallation keeping history"
  print_debug "Note that the chart is uninstalled but the history is kept"
  checkInteractiveMode

  helm::rollbackChart $CHART_RELEASE 2 --namespace $NAMESPACE

  print_info "List chart releases after rollback"
  helm::showChartReleasesByPrefix $CHART_RELEASE -n $NAMESPACE
  helm::historyChart $CHART_RELEASE --namespace $NAMESPACE
  helm::getCustomValues $CHART_RELEASE -n $NAMESPACE

  kubectl::showDeployments -n $NAMESPACE -l $LABELS
  kubectl::showReplicaSets -n $NAMESPACE -l $LABELS
  kubectl::showPods -n $NAMESPACE -l $LABELS
  kubectl::showServices -n $NAMESPACE -l $LABELS
  kubectl::showEndpointsByService $SERVICE_NAME -n $NAMESPACE

  helm::uninstallChart $CHART_RELEASE -n $NAMESPACE

  print_info "List chart releases after uninstallation"
  helm::showChartReleasesByPrefix $CHART_RELEASE -n $NAMESPACE
  helm::historyChart $CHART_RELEASE --namespace $NAMESPACE

  print_info "Check chart uninstallation"
  print_debug "Note that the chart is uninstalled and the history is cleared"
  checkInteractiveMode

  checkCleanupMode
  print_done "Poc completed successfully"
  exit 0
}

#############
# EXECUTION #
#############

main $@
