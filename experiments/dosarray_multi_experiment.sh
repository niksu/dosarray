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
export EXPERIMENT_DURATION=65
export ATTACK_STARTS_AT=10
export ATTACK_LASTS_FOR=20
# FIXME rename GAP_BETWEEN_ROUNDS to clearer name, e.g., DOSARRAY_INTERVAL_BETWEEN_LOAD_POLLS
export GAP_BETWEEN_ROUNDS=5

# We run an attack script in these containers.
# NOTE don't include whitepace before newline.
# NOTE this example can only have one attack at a time -- edit "dosarray_http_experiment" to mix attacks.
export ATTACKERS="is_attacker() { \n\
    grep -F -q -x \"\$1\" <<EOF\n\
c3.2\n\
c4.3\n\
c5.4\n\
c6.5\n\
c7.6\n\
NOc8.7\n\
NOc6.4\n\
NOc7.4\n\
NOc8.4\n\
NOc3.6\n\
NOc4.2\n\
NOc5.3\n\
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
    DESTINATION_DIR="$(pwd)/example_experiment_set_${TARGET}_${ATTACK}"
    dosarray_http_experiment ${TARGET} ${ATTACK} "${EXPERIMENT_DESC}" ${DESTINATION_DIR}
    # FIXME EXPERIMENT_RESET_CMD should depend on TARGET -- in this example we only have one.
    dosarray_execute_on "${HOST_NAME}" "${EXPERIMENT_RESET_CMD}"
    sleep ${INTER_EXPERIMENT_GAP}
  done
  # FIXME currently target is stopped manually
done
