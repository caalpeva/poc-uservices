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

CHART_NAME="loop-message"
CHART_RELEASE="poc-$CHART_NAME"
POD_NAME=$CHART_RELEASE

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

  print_box "UPGRADE CHART AND REUSE VALUES" \
    "" \
    " - Proof of concept about chat upgradation and reuse values."
  checkInteractiveMode

  kubectl::showNodes

  print_info "Before installing the chart, find out what values can be set."
  helm::showDefaultLimitedChartValues 25 "${CHARTS_DIRECTORY}/$CHART_NAME"

  helm::installChartSilently $CHART_RELEASE "${CHARTS_DIRECTORY}/$CHART_NAME" \
    --namespace $NAMESPACE --create-namespace \
    --set env.character=Chayote,env.sleepTime=3s \
    --wait
    #--dry-run

  helm::historyChart $CHART_RELEASE --namespace $NAMESPACE
  helm::getCustomValues $CHART_RELEASE -n $NAMESPACE

  kubectl::showDeployments -n $NAMESPACE -l $LABELS
  kubectl::showReplicaSets -n $NAMESPACE -l $LABELS
  kubectl::showPods -n $NAMESPACE -l $LABELS

  print_info "Wait for a few seconds to show logs..." && sleep 5
  RUNNING_PODS=($(kubectl::getRunningPods -n $NAMESPACE -l $LABELS))
  kubectl::showLogs ${RUNNING_PODS[0]} -n $NAMESPACE -l $LABELS

  helm::upgradeChartSilently $CHART_RELEASE "${CHARTS_DIRECTORY}/$CHART_NAME" \
    --namespace $NAMESPACE \
    --version 10.6.3 \
    --reuse-values
    #--set env.character=Chayote,env.sleepTime=3s

  helm::historyChart $CHART_RELEASE --namespace $NAMESPACE
  helm::getCustomValues $CHART_RELEASE -n $NAMESPACE

  kubectl::showDeployments -n $NAMESPACE -l $LABELS
  kubectl::showReplicaSets -n $NAMESPACE -l $LABELS
  kubectl::showPods -n $NAMESPACE -l $LABELS

  print_info "Wait for a few seconds to show logs again..." && sleep 5
  RUNNING_PODS=($(kubectl::getRunningPods -n $NAMESPACE -l $LABELS))
  kubectl::showLogs ${RUNNING_PODS[0]} -n $NAMESPACE -l $LABELS

  print_info "Check chart upgrade"
  print_debug "Note that the --reuse-values flag keep the last custom values."
  checkInteractiveMode

  helm::upgradeChartSilently $CHART_RELEASE "${CHARTS_DIRECTORY}/$CHART_NAME" \
    --namespace $NAMESPACE \
    --version 10.6.4 \
    --reset-values

  helm::historyChart $CHART_RELEASE --namespace $NAMESPACE
  helm::getCustomValues $CHART_RELEASE -n $NAMESPACE

  kubectl::showDeployments -n $NAMESPACE -l $LABELS
  kubectl::showReplicaSets -n $NAMESPACE -l $LABELS
  kubectl::showPods -n $NAMESPACE -l $LABELS

  print_info "Wait for a few seconds to show logs again..." && sleep 5
  RUNNING_PODS=($(kubectl::getRunningPods -n $NAMESPACE -l $LABELS))
  kubectl::showLogs ${RUNNING_PODS[0]} -n $NAMESPACE -l $LABELS

  print_info "Check chart upgrade again"
  print_debug "Note that the --reset-values flag reset the values to the ones built into the chart."
  print_debug "Note that it uses a second replicaset that groups the new pod that are updated."
  checkInteractiveMode

  checkCleanupMode
  print_done "Poc completed successfully"
  exit 0
}

#############
# EXECUTION #
#############

main $@
