#!/bin/bash

DIR=$(dirname $(readlink -f $0))

source "${DIR}/../../../../dependencies/downloads/poc-bash-master/includes/print-utils.src"
source "${DIR}/../../../../dependencies/downloads/poc-bash-master/includes/trace-utils.src"
source "${DIR}/../../../../dependencies/downloads/poc-bash-master/includes/progress-bar-utils.src"
source "${DIR}/../../../../utils/uservices.src"

KAFKA_HOME=$HOME/tools/kafka_2.13-3.5.0/

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
  if [ -n "$TOPIC_CREATED" ]; then
    print_info "Delete kafka topic"
    $KAFKA_HOME/bin/kafka-topics.sh --delete \
      --topic quickstart-events \
      --bootstrap-server localhost:9092
  fi

  if [ -n "$PID_KAFKA_SERVER" ]; then
    print_info "Kill the execution of kafka server script"
    evalCommand kill -9 $PID_KAFKA_SERVER
  fi

  if [ -n "$PID_ZOOKEEPER_SERVER" ]; then
    print_info "Kill the execution of zookeeper server script"
    evalCommand kill -9 $PID_ZOOKEEPER_SERVER
  fi

  evalCommand rm -rf /tmp/kafka-logs /tmp/zookeeper /tmp/kraft-combined-logs

  evalCommand cd -
}

function sendCommand() {
	tmux send-keys "$1" C-m
}

function executeKafkaProducer() {
	sendCommand "bin/kafka-console-producer.sh --topic quickstart-events \
    --bootstrap-server localhost:9092"
}

function executeKafkaConsumer() {
	sendCommand "bin/kafka-console-consumer.sh --topic quickstart-events \
    --from-beginning \
    --bootstrap-server localhost:9092"
}

function configureConsoleWithTmux() {
	session="poc-kafka-local-$(date '+%Y%m%d%H%M')"

	# set up tmux
	tmux start-server
	tmux new-session -d -s $session -n "dashboard"
	tmux select-window $session:1

	# Select pane 1
	tmux selectp -t 1
	tmux send-keys "bin/kafka-console-producer.sh --topic quickstart-events --bootstrap-server localhost:9092" C-m

	# Split pane 1 horizontal by 50%
	tmux splitw -v -p 50

	# Select pane 2
	tmux selectp -t 2
	tmux send-keys "bin/kafka-console-consumer.sh --topic quickstart-events --from-beginning --bootstrap-server localhost:9092" C-m
	# Split pane 2 horizontal by 50%
	tmux splitw -v -p 50

	# Select pane 3
	tmux selectp -t 3
	tmux send-keys "bin/kafka-console-consumer.sh --topic quickstart-events --from-beginning --bootstrap-server localhost:9092" C-m

	# Select pane 2
	tmux selectp -t 2
	# Split pane 2 horizontal by 50%
	tmux splitw -v -p 50

	# Select pane 4
	tmux selectp -t 4
	tmux send-keys "bin/kafka-console-consumer.sh --topic quickstart-events --from-beginning --bootstrap-server localhost:9092" C-m

	# Select pane 1
	tmux selectp -t 1

	#Activate mouse
	tmux setw -g mouse on

	# Finished setup, attach to the tmux session!
	tmux attach-session -t $session
}

function main {
  print_info "$(basename $0) [PID = $$]"
  checkArguments $@
  initialize

  evalCommand cd $KAFKA_HOME
  print_info "Start the ZooKeeper service"
  evalCommand bin/zookeeper-server-start.sh config/zookeeper.properties &
  PID_ZOOKEEPER_SERVER=$!
  sleep 5 && checkInteractiveMode

  print_info "Start the Kafka broker service"
  evalCommand bin/kafka-server-start.sh config/server.properties &
  PID_KAFKA_SERVER=$!
  sleep 5 && checkInteractiveMode

  print_info "Create a topic to store your events"
  evalCommand bin/kafka-topics.sh --create \
    --topic quickstart-events \
    --bootstrap-server localhost:9092

  evalCommand bin/kafka-topics.sh --describe \
    --topic quickstart-events \
    --bootstrap-server localhost:9092
  TOPIC_CREATED=true
  sleep 3 && checkInteractiveMode

  gnome-terminal -x bash -c "$(declare -f configureConsoleWithTmux);
  export -f configureConsoleWithTmux; configureConsoleWithTmux; bash"
  #configureConsoleWithTmux
  checkInteractiveMode
  checkCleanupMode
  print_done "Poc completed successfully "
  exit 0
}

main $@
