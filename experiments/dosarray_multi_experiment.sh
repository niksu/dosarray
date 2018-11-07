#/bin/sh -e
# Example of using DoSarray
# Nik Sultana, February 2018, UPenn
#
# Targetting Apache using various attacks
# NOTE we can also easily change this to target Nginx and others.

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

# NOTE for HULK you might need to increase the experiment duration (e.g., 165
# for this config when attacking Apache Event, since it takes a longer time
# than usual to recover after the attack).
export DOSARRAY_EXPERIMENT_DURATION=65
export DOSARRAY_ATTACK_STARTS_AT=10
export DOSARRAY_ATTACK_LASTS_FOR=20
export DOSARRAY_INTERVAL_BETWEEN_LOAD_POLLS=5

# We run an attack script in these containers.
# NOTE don't include whitepace before newline.
# NOTE this example can only have one attack at a time -- edit "dosarray_http_experiment" to mix attacks.
export ATTACKERS="is_attacker() { \n\
    grep -F -q -x \"\$1\" <<EOF\n\
${DOSARRAY_CONTAINER_PREFIX}3.2\n\
${DOSARRAY_CONTAINER_PREFIX}4.3\n\
${DOSARRAY_CONTAINER_PREFIX}5.4\n\
${DOSARRAY_CONTAINER_PREFIX}6.5\n\
${DOSARRAY_CONTAINER_PREFIX}7.6\n\
NO${DOSARRAY_CONTAINER_PREFIX}8.7\n\
NO${DOSARRAY_CONTAINER_PREFIX}6.4\n\
NO${DOSARRAY_CONTAINER_PREFIX}7.4\n\
NO${DOSARRAY_CONTAINER_PREFIX}8.4\n\
NO${DOSARRAY_CONTAINER_PREFIX}3.6\n\
NO${DOSARRAY_CONTAINER_PREFIX}4.2\n\
NO${DOSARRAY_CONTAINER_PREFIX}5.3\n\
EOF\n\
}\n"

# NOTE for resetting the target:
HOST_NAME=dedos01
INTER_EXPERIMENT_GAP=20
EXPERIMENT_RESET_CMD="/home/nsultana/src/prefix/bin/apachectl -k restart"

EXPERIMENT_DESC="Default config"
TARGETS=( apache_worker )
# Examples of other targets that have been used:
#   nginx, lighttpd, apache_event, varnish, haproxy.
ATTACKS=( slowloris goldeneye torshammer hulk none )

for TARGET in "${TARGETS[@]}"
do
  # FIXME currently target is started manually
  for ATTACK in "${ATTACKS[@]}"
  do
    DOSARRAY_DESTINATION_DIR="$(pwd)/example_experiment_set_${TARGET}_${ATTACK}"
    dosarray_http_experiment ${TARGET} ${ATTACK} "${EXPERIMENT_DESC}" ${DOSARRAY_DESTINATION_DIR}
    # FIXME EXPERIMENT_RESET_CMD should depend on TARGET -- in this example we only have one.
    dosarray_execute_on "${HOST_NAME}" "${EXPERIMENT_RESET_CMD}"
    sleep ${INTER_EXPERIMENT_GAP}
  done
  # FIXME currently target is stopped manually
done
