#/bin/sh -e
# Monitors the clusters' servers for various kinds of loads.
# Nik Sultana, February 2018, UPenn
#
# Polls various kinds of load on a collection of machines for $NUM_ROUNDS times,
# sleeping $DOSARRAY_INTERVAL_BETWEEN_LOAD_POLLS between polls. After downloading the results,
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

if [ -z "${DOSARRAY_DESTINATION_DIR}" ]
then
  echo "\$DOSARRAY_DESTINATION_DIR needs to be defined" >&2
  exit 2
fi

if [ -z "${DOSARRAY_INTERVAL_BETWEEN_LOAD_POLLS}" ]
then
  echo "Need to define \$DOSARRAY_INTERVAL_BETWEEN_LOAD_POLLS" >&2
  exit 1
fi

echo "DOSARRAY_INTERVAL_BETWEEN_LOAD_POLLS=${DOSARRAY_INTERVAL_BETWEEN_LOAD_POLLS}"

if [ -z ${DOSARRAY_EXPERIMENT_DURATION} ]
then
  echo "Need to define \$EXPERIMENT_DURATION" >&2
  exit 1
fi

if [ -n "${DOSARRAY_EXPERIMENT_DURATION}" ]
then
  echo "DOSARRAY_EXPERIMENT_DURATION=${DOSARRAY_EXPERIMENT_DURATION}"
  NUM_ROUNDS=$(echo "${DOSARRAY_EXPERIMENT_DURATION} / ${DOSARRAY_INTERVAL_BETWEEN_LOAD_POLLS}" | bc -l)
  NUM_ROUNDS=$( printf "%.0f" ${NUM_ROUNDS} )
fi

if [ -z "${NUM_ROUNDS}" ]
then
  echo "Need to define \$NUM_ROUNDS or \$DOSARRAY_EXPERIMENT_DURATION" >&2
  exit 1
fi
echo "NUM_ROUNDS=${NUM_ROUNDS}"

function logname_of_load() {
  HOST_NAME="$1"
  echo "${HOST_NAME}_load.log"
}

function logname_of_mem() {
  HOST_NAME="$1"
  echo "${HOST_NAME}_mem.log"
}

function logname_of_net() {
  HOST_NAME="$1"
  echo "${HOST_NAME}_net.log"
}

LOAD_MEASURE_SCRIPT="dosarray_measure_load.sh"

for HOST_NAME in "${DOSARRAY_PHYSICAL_HOSTS_PUB[@]}"
do
  dosarray_scp_to ${HOST_NAME} src/${LOAD_MEASURE_SCRIPT} ${DOSARRAY_LOG_PATH_PREFIX}
done

for HOST_NAME in "${DOSARRAY_PHYSICAL_HOSTS_PUB[@]}"
do
  dosarray_execute_on ${HOST_NAME} "nohup ${DOSARRAY_LOG_PATH_PREFIX}/${LOAD_MEASURE_SCRIPT} ${DOSARRAY_INTERVAL_BETWEEN_LOAD_POLLS} ${DOSARRAY_EXPERIMENT_DURATION} ${NUM_ROUNDS} &"
done

sleep ${DOSARRAY_EXPERIMENT_DURATION}

for HOST_NAME in "${DOSARRAY_PHYSICAL_HOSTS_PUB[@]}"
do
  dosarray_scp_from ${HOST_NAME} "${DOSARRAY_LOG_PATH_PREFIX}/$(logname_of_load ${HOST_NAME})" ${DOSARRAY_DESTINATION_DIR}
  dosarray_scp_from ${HOST_NAME} "${DOSARRAY_LOG_PATH_PREFIX}/$(logname_of_mem ${HOST_NAME})" ${DOSARRAY_DESTINATION_DIR}
  dosarray_scp_from ${HOST_NAME} "${DOSARRAY_LOG_PATH_PREFIX}/$(logname_of_net ${HOST_NAME})" ${DOSARRAY_DESTINATION_DIR}
  dosarray_execute_on ${HOST_NAME} "rm ${DOSARRAY_LOG_PATH_PREFIX}/${LOAD_MEASURE_SCRIPT}"
  dosarray_execute_on ${HOST_NAME} "rm ${DOSARRAY_LOG_PATH_PREFIX}/${HOST_NAME}_*.log"
done

${DOSARRAY_SCRIPT_DIR}/src/dosarray_filter_net_logs.sh

python ${DOSARRAY_SCRIPT_DIR}/src/generate_load_chart.py -p ${DOSARRAY_DESTINATION_DIR} -i 5 -t load -o column -m ${DOSARRAY_PHYSICAL_HOSTS_PUB[@]} > ${DOSARRAY_DESTINATION_DIR}/load.data
python ${DOSARRAY_SCRIPT_DIR}/src/generate_load_chart.py -p ${DOSARRAY_DESTINATION_DIR} -i 5 -t mem -o column -m  ${DOSARRAY_PHYSICAL_HOSTS_PUB[@]} > ${DOSARRAY_DESTINATION_DIR}/mem.data
python ${DOSARRAY_SCRIPT_DIR}/src/generate_load_chart.py -p ${DOSARRAY_DESTINATION_DIR} -i 5 -t net_rx -o column -m ${DOSARRAY_PHYSICAL_HOSTS_PUB[@]} > ${DOSARRAY_DESTINATION_DIR}/net_rx.data
python ${DOSARRAY_SCRIPT_DIR}/src/generate_load_chart.py -p ${DOSARRAY_DESTINATION_DIR} -i 5 -t net_tx -o column -m ${DOSARRAY_PHYSICAL_HOSTS_PUB[@]} > ${DOSARRAY_DESTINATION_DIR}/net_tx.data
python ${DOSARRAY_SCRIPT_DIR}/src/generate_load_chart.py -p ${DOSARRAY_DESTINATION_DIR} -i 5 -t net_rxerrors -o column -m ${DOSARRAY_PHYSICAL_HOSTS_PUB[@]} > ${DOSARRAY_DESTINATION_DIR}/net_rxerrors.data
python ${DOSARRAY_SCRIPT_DIR}/src/generate_load_chart.py -p ${DOSARRAY_DESTINATION_DIR} -i 5 -t net_txerrors -o column -m ${DOSARRAY_PHYSICAL_HOSTS_PUB[@]} > ${DOSARRAY_DESTINATION_DIR}/net_txerrors.data

echo "Done"
