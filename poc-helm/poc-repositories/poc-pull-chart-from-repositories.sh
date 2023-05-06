#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../utils/uservices.src"
source "${DIR}/../utils/helm.src"

#############
# VARIABLES #
#############

TMP_DIRECTORY="${DIR}/tmp"

CHARTS_DIRECTORY="${DIR}/charts"

CHART_NAME="mysql"

#############
# FUNCTIONS #
#############

function initialize() {
  print_info "Preparing poc environment..."
  setTerminalSignals
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
  helm::removeRepo stable
  helm::removeRepo incubator
  helm::removeRepo bitnami
  evalCommand rm -rf ${TMP_DIRECTORY}
}

function main() {
  print_debug "$(basename $0) [PID = $$]"
  checkArguments $@

  initialize

  print_box "PULL CHART FROM REPOSITORY" \
    "" \
    " - Proof of concept about chart pulling from repository."
  checkInteractiveMode

  print_info "Add a repository reference"
  helm::addRepo bitnami	https://charts.bitnami.com/bitnami
  checkInteractiveMode

  helm::listRepos
  helm::updateRepos
  helm::searchChartsFromRepos $CHART_NAME

  print_info "Pull chart from local registry"
  helm::pullChart "bitnami/$CHART_NAME" \
    --destination $TMP_DIRECTORY
    # --version x.x.x

  print_info "Check that the chart archive has been downloaded"
  evalCommand ls -l $TMP_DIRECTORY
  checkInteractiveMode

  checkCleanupMode
  print_done "Poc completed successfully "
  exit 0
}

#############
# EXECUTION #
#############

main $@
