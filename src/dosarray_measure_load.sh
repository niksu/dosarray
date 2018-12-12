#/bin/sh -e
# Collects the load on each host by executing in the host
# Shilpi Bose, December 2018, UPenn
#
# Polls various kinds of load on a collection of machines for $NUM_ROUNDS times,
# sleeping $INTERVAL_BETWEEN_LOAD_POLLS between polls. After downloading the results,
# they're analysed and graphed.

INTERVAL_BETWEEN_LOAD_POLLS=$1
EXPERIMENT_DURATION=$2
NUM_ROUNDS=$3
HOST_NAME=`hostname`

echo ${HOSTNAME}

if [ -z "${INTERVAL_BETWEEN_LOAD_POLLS}" ]
then
  echo "Need to define \$INTERVAL_BETWEEN_LOAD_POLLS" >&2
  exit 1
fi

if [ -z "${EXPERIMENT_DURATION}" ]
then
  echo "Need to define \$EXPERIMENT_DURATION" >&2
  exit 1
fi

if [ -z "${NUM_ROUNDS}" ]
then
  echo "Need to define \$NUM_ROUNDS or \$EXPERIMENT_DURATION" >&2
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

for ROUND in `seq 0 ${NUM_ROUNDS}`
do
  echo "Logging round ${ROUND} of ${HOST_NAME}"

  echo "$(hostname) $(date +%s) $(cat /proc/loadavg)" >> "${HOST_NAME}_load.log" &
  echo "$(hostname) $(date +%s) $(grep Mem /proc/meminfo)" >> "${HOST_NAME}_mem.log" &
  echo "cat /proc/net/dev" >> "${HOST_NAME}_net.log" &

  if [ "${ROUND}" -ne "${NUM_ROUNDS}" ]
  then
    sleep ${INTERVAL_BETWEEN_LOAD_POLLS}
  fi
done