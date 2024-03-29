#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../../utils/uservices.src"
source "${DIR}/../../../poc-k8s/utils/kubectl.src"
source "${DIR}/../../utils/helm.src"

#############
# VARIABLES #
#############

NAMESPACE="poc-charts"

CHARTS_DIRECTORY="${DIR}/charts"
TEMPLATE_DIRECTORY="${DIR}/charts/${CHART_NAME}/templates"

CHART_NAME="mysql"
CHART_RELEASE="poc-$CHART_NAME"
SERVICE_NAME=$CHART_RELEASE
SECRET_NAME=$CHART_RELEASE

MYSQL_DATABASE="TENNIS"

LOCAL_PORT=3306

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
  helm::uninstallChart $CHART_RELEASE --namespace $NAMESPACE
  kubectl delete ns $NAMESPACE
}

function showDatabase {
  POD_NAME=$1
  MYSQL_ROOT_PASSWORD=$2
  xtrace on
  kubectl -n $NAMESPACE exec $POD_NAME -- \
    mysql -uroot -p${MYSQL_ROOT_PASSWORD} ${MYSQL_DATABASE} \
    --table -e "select * from COUNTRIES"

  kubectl -n $NAMESPACE exec $POD_NAME -- \
    mysql -uroot -p${MYSQL_ROOT_PASSWORD} ${MYSQL_DATABASE} \
    --table -e "select * from PLAYERS"
  xtrace off
  sleep 1

  checkInteractiveMode
}

function updateDatabase {
  xtrace on
  kubectl -n $NAMESPACE exec $1 -- \
    mysql -uroot -p${MYSQL_ROOT_PASSWORD} ${MYSQL_DATABASE} \
    -e "source /opt/update.sql"
  xtrace off
  sleep 1

  checkInteractiveMode
}


function main() {
  print_debug "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  print_box "GENERATE K8S MANIFESTS VIA TEMPLATE" \
    "" \
    " - Proof of concept about k8s manifests creation from templates"
  checkInteractiveMode

  kubectl::showNodes

  helm::templateFiles "${CHARTS_DIRECTORY}/$CHART_NAME" \
    "templates/configmap-scripts.yaml"

  helm::templateFiles "${CHARTS_DIRECTORY}/$CHART_NAME" \
    "templates/secrets.yaml"

  helm::templateFiles "${CHARTS_DIRECTORY}/$CHART_NAME" \
    "templates/deployment.yaml"

  helm::installChart $CHART_RELEASE "${CHARTS_DIRECTORY}/$CHART_NAME" \
    --namespace $NAMESPACE --create-namespace \
    --wait

  print_info "Show chart instance"
  helm::showChartReleasesByPrefix $CHART_RELEASE -n $NAMESPACE

  kubectl::showDeployments -n $NAMESPACE
  kubectl::showReplicaSets -n $NAMESPACE
  kubectl::showPods -n $NAMESPACE
  kubectl::showServices -n $NAMESPACE
  kubectl::showEndpointsByService $SERVICE_NAME -n $NAMESPACE

  print_info "Decode mysql-root-password value"
  MYSQL_ROOT_PASSWORD=$(kubectl::decodeSecretByKey ${SECRET_NAME} "mysql-root-password" -n $NAMESPACE)
  echo $MYSQL_ROOT_PASSWORD

  POD_NAME=$(kubectl get pods --namespace poc-charts -o jsonpath="{.items[0].metadata.name}")
  print_info "Show database"
  showDatabase ${POD_NAME} ${MYSQL_ROOT_PASSWORD}

  print_info "Update database"
  updateDatabase ${POD_NAME} ${MYSQL_ROOT_PASSWORD}

  print_info "Show database after update data"
  showDatabase ${POD_NAME} ${MYSQL_ROOT_PASSWORD}

  checkCleanupMode
  print_done "Poc completed successfully"
  exit 0
}

#############
# EXECUTION #
#############

main $@
