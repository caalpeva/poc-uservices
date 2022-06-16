#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../../dependencies/downloads/poc-bash-master/includes/progress-bar-utils.src"
source "${DIR}/../../../utils/microservices-utils.src"
source "${DIR}/../../../poc-docker/utils/docker.src"
source "${DIR}/../../utils/kubectl.src"

CONFIG_DIR=${DIR}/config
CONFIGFILE_DEPLOYMENT_01=${CONFIG_DIR}/deployment-01.yaml
CONFIGFILE_DEPLOYMENT_02=${CONFIG_DIR}/deployment-02.yaml
CONFIGFILE_INGRESS=${CONFIG_DIR}/ingress.yaml

INGRESS_CONTROLLER_NAMESPACE="ingress-nginx"
INGRESS_SERVICE_NAME="ingress-nginx-controller"

DEPLOYMENT_SERVER_01_NAME="poc-deployment-01"
DEPLOYMENT_SERVER_02_NAME="poc-deployment-02"
INGRESS_NAME="poc-ingress-from-domains"
POC_LABEL_VALUE=$INGRESS_NAME
DOMAIN_01="myk8s.poc"
DOMAIN_02="myk8s2.poc"

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
  kubectl::unapply $CONFIGFILE_INGRESS \
    $CONFIGFILE_DEPLOYMENT_01 \
    $CONFIGFILE_DEPLOYMENT_02
}

function main {
  print_info "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  kubectl::showNodes
  kubectl::apply $CONFIGFILE_DEPLOYMENT_01 \
    $CONFIGFILE_DEPLOYMENT_02 \
    $CONFIGFILE_INGRESS
  kubectl::waitForDeployment $DEPLOYMENT_SERVER_01_NAME
  kubectl::waitForDeployment $DEPLOYMENT_SERVER_02_NAME
  kubectl::showDeployments -l "poc=$POC_LABEL_VALUE"
  kubectl::showReplicaSets -l "poc=$POC_LABEL_VALUE"
  kubectl::showPods -l "poc=$POC_LABEL_VALUE"
  kubectl::showServices -l "poc=$POC_LABEL_VALUE"
  kubectl::showEndpointsByLabels -l "poc=$POC_LABEL_VALUE"

  sleep 5 && kubectl::showIngresses
  kubectl::showIngressesDescription $INGRESS_NAME

  print_info "Extract node port from ingress controller service"
  NODE_PORT=$(kubectl::getNodePortByService ${INGRESS_SERVICE_NAME} http -n $INGRESS_CONTROLLER_NAMESPACE)
  echo $NODE_PORT
  checkInteractiveMode

  print_info "check access to an application with external ip and another via domain"
  print_debug "Note that the port has been enabled on all nodes"
  NODE_ADDRESSES=$(kubectl::getNodeAddresses)
  for NODE_ADDRESS in ${NODE_ADDRESSES[@]}
  do
    RESOLVE_STRING="--resolve '$DOMAIN_01:$NODE_PORT:$NODE_ADDRESS'"
    executeCurl http://$DOMAIN_01:$NODE_PORT/echo $RESOLVE_STRING
    if [ $? -ne 0 ]
    then
      print_error "Http server from $DOMAIN_01:$NODE_PORT is not available"
      SERVER_AVAILABLE=false
    fi
    RESOLVE_STRING="--resolve '$DOMAIN_02:$NODE_PORT:$NODE_ADDRESS'"
    executeCurl http://$DOMAIN_02:$NODE_PORT/ $RESOLVE_STRING
    if [ $? -ne 0 ]
    then
      print_error "Http server from $DOMAIN_02:$NODE_PORT is not available"
      SERVER_AVAILABLE=false
    fi
  done
  checkInteractiveMode

  print_info "Check access from traditional port 80 via proxy"
  print_debug "Only if a proxy is used on the master node to redirect traffic from the traditional"
  print_debug "ports (80 for HTTP and 443 for HTTPS) to the ports exposed by the ingress controller"
  print_debug "Note that the port 80 has only been enabled on master node"
  NODE_PORT=80
  NODE_ADDRESSES=$(kubectl::getNodeAddresses)
  for NODE_ADDRESS in ${NODE_ADDRESSES[@]}
  do
    RESOLVE_STRING="--resolve '$DOMAIN_01:$NODE_PORT:$NODE_ADDRESS'"
    executeCurl http://$DOMAIN_01:$NODE_PORT/echo $RESOLVE_STRING
    if [ $? -ne 0 ]
    then
      print_warn "Http server from $DOMAIN_01:$NODE_PORT is not available"
      SERVER_AVAILABLE=false
    fi
    RESOLVE_STRING="--resolve '$DOMAIN_02:$NODE_PORT:$NODE_ADDRESS'"
    executeCurl http://$DOMAIN_02:$NODE_PORT/ $RESOLVE_STRING
    if [ $? -ne 0 ]
    then
      print_warn "Http server from $DOMAIN_02:$NODE_PORT is not available"
      SERVER_AVAILABLE=false
    fi
  done
  checkInteractiveMode

  checkCleanupMode
  print_done "Poc completed successfully"
  exit 0
}

main $@
