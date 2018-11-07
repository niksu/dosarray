#/bin/sh -e
# Example of using DoSarray
# Nik Sultana, June 2018, UPenn
#
# Targetting DeDOS using various attacks
# NOTE this is based on  experiments/dosarray_multi_experiment.sh
#
# NOTE I set latency_scale to 10.0 for the availability analysis,
#      since DeDOS has a ~4x higher latency than other systems.

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

source "${DOSARRAY_SCRIPT_DIR}/experiments/dosarray_experiment.sh"

export DOSARRAY_EXPERIMENT_DURATION=165
export DOSARRAY_ATTACK_STARTS_AT=10
export DOSARRAY_ATTACK_LASTS_FOR=20
export DOSARRAY_INTERVAL_BETWEEN_LOAD_POLLS=5

export DOSARRAY_HTTP_SSL=1

NUM_ATTACKERS=50

dosarray_evenly_distribute_attackers ${NUM_ATTACKERS}

# NOTE for resetting the target:
HOST_NAME=dedos01
INTER_EXPERIMENT_GAP=20
#EXPERIMENT_RESET_CMD="/home/nsultana/src/prefix/bin/apachectl -k restart" FIXME unused

EXPERIMENT_DESC="Default config"
TARGETS=( dedos_web )
ATTACKS=( slowloris goldeneye torshammer hulk none )

for TARGET in "${TARGETS[@]}"
do
  # FIXME currently target is started manually
  for ATTACK in "${ATTACKS[@]}"
  do
    DOSARRAY_DESTINATION_DIR="$(pwd)/example_experiment_set_${TARGET}_${ATTACK}_${NUM_ATTACKERS}attackers"
    dosarray_http_experiment ${TARGET} ${ATTACK} "${EXPERIMENT_DESC}" ${DOSARRAY_DESTINATION_DIR}
    # FIXME EXPERIMENT_RESET_CMD not being used
#    dosarray_execute_on "${HOST_NAME}" "${EXPERIMENT_RESET_CMD}"
    sleep ${INTER_EXPERIMENT_GAP}
  done
  # FIXME currently target is stopped manually
done
