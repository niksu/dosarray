#/bin/sh -e
# Experimental setup for the Winnow project.
# Nik Sultana, February 2018, UPenn
#
# Downloads load indicators from a collection of machines for $NUM_ROUNDS times,
# sleeping $GAP_BETWEEN_ROUNDS between downloads.

if [ -z "${DOSARRAY_SCRIPT_DIR}" ]
then
  echo "Need to configure DoSarray -- set \$DOSARRAY_SCRIPT_DIR" >&2
  exit 1
elif [ ! -e "${DOSARRAY_SCRIPT_DIR}/dosarray_config.sh" ]
then
  echo "Need to configure DoSarray -- could not find dosarray_config.sh at \$DOSARRAY_SCRIPT_DIR ($DOSARRAY_SCRIPT_DIR)" >&2
  exit 1
fi
source "${DOSARRAY_SCRIPT_DIR}/dosarray_config.sh"

# FIXME make $GAP_BETWEEN_ROUNDS as the main parameter to drive this,
#       rather than $NUM_ROUNDS. Put in dosarray_config.sh
if [ -z "${NUM_ROUNDS}" ]
then
  echo "Need to define \$NUM_ROUNDS" >&2
  exit 1
fi

echo "NUM_ROUNDS=${NUM_ROUNDS}"

if [ -n "${EXPERIMENT_DURATION}" ]
then
  echo "EXPERIMENT_DURATION=${EXPERIMENT_DURATION}"
  GAP_BETWEEN_ROUNDS=$(echo "${EXPERIMENT_DURATION} / ${NUM_ROUNDS}" | bc -l)
fi

if [ -z "${GAP_BETWEEN_ROUNDS}" ]
then
  echo "Need to define \$GAP_BETWEEN_ROUNDS or \$EXPERIMENT_DURATION" >&2
  exit 1
fi
echo "GAP_BETWEEN_ROUNDS=${GAP_BETWEEN_ROUNDS}"

function logname_of_load() {
  HOST_NAME="$1"
  # FIXME put in ${DESTINATION_DIR}
  echo "${HOST_NAME}_load.log"
}

function logname_of_mem() {
  HOST_NAME="$1"
  # FIXME put in ${DESTINATION_DIR}
  echo "${HOST_NAME}_mem.log"
}

function logname_of_net() {
  HOST_NAME="$1"
  # FIXME put in ${DESTINATION_DIR}
  echo "${HOST_NAME}_net.log"
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
    echo "\$(hostname) \$(date +%s) \$(grep Mem /proc/meminfo)" >> $(logname_of_mem ${HOST_NAME}) &
    echo "Mem log: $(logname_of_load ${HOST_NAME})"

    dosarray_execute_on "${HOST_NAME}" \
    "cat /proc/net/dev" >> $(logname_of_net ${HOST_NAME}) &
    echo "Net log: $(logname_of_load ${HOST_NAME})"
  done

  if [ "${ROUND}" -ne "${NUM_ROUNDS}" ]
  then
    sleep ${GAP_BETWEEN_ROUNDS}
  fi
done

echo "Done"
