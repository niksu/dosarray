#/bin/sh -e
# Monitors the clusters' servers for various kinds of loads.
# Nik Sultana, February 2018, UPenn
#
# Polls various kinds of load on a collection of machines for $NUM_ROUNDS times,
# sleeping $INTERVAL_BETWEEN_LOAD_POLLS between polls. After downloading the results,
# they're analysed and graphed.

if [ -z "${DOSARRAY_SCRIPT_DIR}" ]
then
  echo "Need to configure DoSarray -- set \$DOSARRAY_SCRIPT_DIR" >&2
  exit 1
elif [ ! -e "${DOSARRAY_SCRIPT_DIR}/config/dosarray_config.sh" ]
then
  echo "Need to configure DoSarray -- could not find dosarray_config.sh at \$DOSARRAY_SCRIPT_DIR/config (${DOSARRAY_SCRIPT_DIR}/config)" >&2
  exit 1
fi
source "${DOSARRAY_SCRIPT_DIR}/config/dosarray_config.sh"

if [ -z "${DESTINATION_DIR}" ]
then
  echo "\$DESTINATION_DIR needs to be defined" >&2
  exit 2
fi

if [ -z "${INTERVAL_BETWEEN_LOAD_POLLS}" ]
then
  echo "Need to define \$INTERVAL_BETWEEN_LOAD_POLLS" >&2
  exit 1
fi

echo "INTERVAL_BETWEEN_LOAD_POLLS=${INTERVAL_BETWEEN_LOAD_POLLS}"

if [ -n "${EXPERIMENT_DURATION}" ]
then
  echo "EXPERIMENT_DURATION=${EXPERIMENT_DURATION}"
  NUM_ROUNDS=$(echo "${EXPERIMENT_DURATION} / ${INTERVAL_BETWEEN_LOAD_POLLS}" | bc -l)
  NUM_ROUNDS=$( printf "%.0f" ${NUM_ROUNDS} )
fi

if [ -z "${NUM_ROUNDS}" ]
then
  echo "Need to define \$NUM_ROUNDS or \$EXPERIMENT_DURATION" >&2
  exit 1
fi
echo "NUM_ROUNDS=${NUM_ROUNDS}"

function logname_of_load() {
  HOST_NAME="$1"
  echo "${DESTINATION_DIR}/${HOST_NAME}_load.log"
}

function logname_of_mem() {
  HOST_NAME="$1"
  echo "${DESTINATION_DIR}/${HOST_NAME}_mem.log"
}

function logname_of_net() {
  HOST_NAME="$1"
  echo "${DESTINATION_DIR}/${HOST_NAME}_net.log"
}

echo "Number of hosts: ${#DOSARRAY_PHYSICAL_HOSTS_PUB[@]}"

for HOST_NAME in "${DOSARRAY_PHYSICAL_HOSTS_PUB[@]}"
do
  echo "Clearing logs of ${HOST_NAME}"
  rm -f $(logname_of_load ${HOST_NAME})
  rm -f $(logname_of_mem ${HOST_NAME})
  rm -f $(logname_of_net ${HOST_NAME})
done

for ROUND in `seq 0 ${NUM_ROUNDS}`
do
  for HOST_NAME in "${DOSARRAY_PHYSICAL_HOSTS_PUB[@]}"
  do
    echo "Logging round ${ROUND} of ${HOST_NAME}"
    dosarray_execute_on "${HOST_NAME}" \
    "echo \$(hostname) \$(date +%s) \$(cat /proc/loadavg)" >> $(logname_of_load ${HOST_NAME}) &
    echo "Load log: $(logname_of_load ${HOST_NAME})"

    dosarray_execute_on "${HOST_NAME}" \
    "echo \$(hostname) \$(date +%s) \$(grep Mem /proc/meminfo)" >> $(logname_of_mem ${HOST_NAME}) &
    echo "Mem log: $(logname_of_mem ${HOST_NAME})"

    dosarray_execute_on "${HOST_NAME}" \
    "cat /proc/net/dev" >> $(logname_of_net ${HOST_NAME}) &
    echo "Net log: $(logname_of_net ${HOST_NAME})"
  done

  if [ "${ROUND}" -ne "${NUM_ROUNDS}" ]
  then
    sleep ${INTERVAL_BETWEEN_LOAD_POLLS}
  fi
done

sleep ${INTERVAL_BETWEEN_LOAD_POLLS}

${DOSARRAY_SCRIPT_DIR}/src/dosarray_filter_net_logs.sh

python ${DOSARRAY_SCRIPT_DIR}/src/generate_load_chart.py -p ${DESTINATION_DIR} -i 5 -t load -o column -m ${DOSARRAY_PHYSICAL_HOSTS_PUB[@]} > ${DESTINATION_DIR}/load.data
python ${DOSARRAY_SCRIPT_DIR}/src/generate_load_chart.py -p ${DESTINATION_DIR} -i 5 -t mem -o column -m  ${DOSARRAY_PHYSICAL_HOSTS_PUB[@]} > ${DESTINATION_DIR}/mem.data
python ${DOSARRAY_SCRIPT_DIR}/src/generate_load_chart.py -p ${DESTINATION_DIR} -i 5 -t net_rx -o column -m ${DOSARRAY_PHYSICAL_HOSTS_PUB[@]} > ${DESTINATION_DIR}/net_rx.data
python ${DOSARRAY_SCRIPT_DIR}/src/generate_load_chart.py -p ${DESTINATION_DIR} -i 5 -t net_tx -o column -m ${DOSARRAY_PHYSICAL_HOSTS_PUB[@]} > ${DESTINATION_DIR}/net_tx.data
python ${DOSARRAY_SCRIPT_DIR}/src/generate_load_chart.py -p ${DESTINATION_DIR} -i 5 -t net_rxerrors -o column -m ${DOSARRAY_PHYSICAL_HOSTS_PUB[@]} > ${DESTINATION_DIR}/net_rxerrors.data
python ${DOSARRAY_SCRIPT_DIR}/src/generate_load_chart.py -p ${DESTINATION_DIR} -i 5 -t net_txerrors -o column -m ${DOSARRAY_PHYSICAL_HOSTS_PUB[@]} > ${DESTINATION_DIR}/net_txerrors.data

echo "Done"
