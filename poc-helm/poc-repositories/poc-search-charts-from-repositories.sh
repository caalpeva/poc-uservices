#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../utils/uservices.src"
source "${DIR}/../utils/helm.src"

#############
# VARIABLES #
#############

CHART_FILTER="tomcat"

#############
# FUNCTIONS #
#############

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

function cleanup() {
  print_debug "Cleaning environment..."
  helm::removeRepo stable
  helm::removeRepo incubator
  helm::removeRepo bitnami
}

function main() {
  print_debug "$(basename $0) [PID = $$]"
  checkArguments $@

  initialize

  print_box "HELM CHART REPOSITORIES" \
    "" \
    " - Similar to the docker hub, which is a hosting platform for docker images." \
    "   The most popular Helm Chart package hosting platform is Artifact Hub." \
    "   There are many Chart repositories on Artifact Hub."
  checkInteractiveMode

  helm::showSearchUsage
  helm::searchChartsFromHub $CHART_FILTER

  print_info "Add a repository reference"
  helm::addRepo stable https://charts.helm.sh/stable
  checkInteractiveMode

  helm::listRepos
  helm::searchChartsFromRepos $CHART_FILTER

  print_info "Add more repository references"
  helm::addRepo incubator https://charts.helm.sh/incubator
  helm::addRepo bitnami	https://charts.bitnami.com/bitnami
  checkInteractiveMode

  helm::listRepos
  helm::searchChartsFromRepos $CHART_FILTER #--versions 

  helm::updateRepos
  helm::searchChartsFromRepos $CHART_FILTER

  print_info "Remove repository"
  helm::removeRepo incubator
  checkInteractiveMode

  helm::listRepos

  checkCleanupMode
  print_done "Poc completed successfully "
  exit 0
}

#############
# EXECUTION #
#############

main $@
