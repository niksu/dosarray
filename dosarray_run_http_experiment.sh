#/bin/sh -e
# DoSarray setup for HTTP
# Nik Sultana, December 2017, UPenn
#
# Use of this source code is governed by the Apache 2.0 license; see LICENSE

if [ -z "${DOSARRAY_SCRIPT_DIR}" ]
then
  echo "\$DOSARRAY_SCRIPT_DIR needs to be defined" >&2
  exit 2
fi

source ${DOSARRAY_SCRIPT_DIR}/dosarray_http_experiment_options.sh

SERVER_CHOICE=$1
ATTACK_CHOICE=$2

if [ -z "${DESTINATION_DIR}" ]
then
  echo "\$DESTINATION_DIR needs to be defined" >&2
  exit 2
fi

if [ -d "${DESTINATION_DIR}" ]
then
  echo "\$DESTINATION_DIR (${DESTINATION_DIR}) already exists" >&2
  exit 2
fi

if [ -z "${TITLE}" ]
then
  echo "\$TITLE needs to be defined" >&2
  exit 2
fi


# We run an attack script in these containers.
# NOTE don't include whitepace before newline.
# NOTE we can only have one attack at a time -- can't yet mix attacks.
ATTACKERS="is_attacker() { \n\
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

if [ "${SERVER_CHOICE}" == "nginx" ]
then
  SERVER_PORT="${PORT_Nginx}"
elif [ "${SERVER_CHOICE}" == "apache_worker" ]
then
  SERVER_PORT="${PORT_Apache_Worker}"
elif [ "${SERVER_CHOICE}" == "apache_event" ]
then
  SERVER_PORT="${PORT_Apache_Event}"
elif [ "${SERVER_CHOICE}" == "lighttpd" ]
then
  SERVER_PORT="${PORT_lighttpd}"
elif [ "${SERVER_CHOICE}" == "haproxy" ]
then
  SERVER_PORT="${PORT_HAproxy}"
elif [ "${SERVER_CHOICE}" == "varnish" ]
then
  SERVER_PORT="${PORT_Varnish}"
else
  echo "Unknown server choice: '${SERVER_CHOICE}'" >&2
  exit 1
fi
echo "SERVER_PORT=${SERVER_PORT}" >&2

# Check that server is running -- prompt user to activate it.
${DOSARRAY_SCRIPT_DIR}/dosarray_http_server_test.sh "${SERVER_CHOICE}"
TEST_RESULT="$?"
if [ "${TEST_RESULT}" -ne "200" ]
then
  echo "Server (${SERVER_CHOICE}) doesn't appear to be running"
  exit 2
fi

if [ "${ATTACK_CHOICE}" == "slowloris" ]
then
  ATTACK="${ATTACK_Slowloris}"
elif [ "${ATTACK_CHOICE}" == "goldeneye" ]
then
  ATTACK="${ATTACK_GoldenEye}"
elif [ "${ATTACK_CHOICE}" == "torshammer" ]
then
  ATTACK="${ATTACK_TorsHammer}"
elif [ "${ATTACK_CHOICE}" == "none" ]
then
  ATTACK="${ATTACK_Slowloris}" # The actual attack doesn't matter since $ATTACKERS is set to empty predicate.
ATTACKERS="is_attacker() { \n\
    grep -F -q -x \"\$1\" <<EOF\n\
EOF\n\
}\n"
else
  echo "Unknown attack choice: '${ATTACK_CHOICE}'" >&2
  exit 1
fi

# Units are "seconds"
[ -z "${EXPERIMENT_DURATION}" ] && EXPERIMENT_DURATION=60
# Number of instances on each machine
[ -z "${DOSARRAY_VIRT_INSTANCES}" ] && DOSARRAY_VIRT_INSTANCES=40

# All units are "seconds"
[ -z "${ATTACK_STARTS_AT}" ] && ATTACK_STARTS_AT=10
# NOTE The attack can end before $ATTACK_LASTS_FOR has elapsed -- it depends on
#      the attack script -- but the attack cannot last longer than
#      $ATTACK_LASTS_FOR.
[ -z "${ATTACK_LASTS_FOR}" ] && ATTACK_LASTS_FOR=20

# FIXME check that these values are sensible wrt each other -- e.g., that an attack doesn't last longer than the experiment.
echo "EXPERIMENT_DURATION=${EXPERIMENT_DURATION}"
echo "DOSARRAY_VIRT_INSTANCES=${DOSARRAY_VIRT_INSTANCES}"
echo "ATTACK_STARTS_AT=${ATTACK_STARTS_AT}"
echo "ATTACK_LASTS_FOR=${ATTACK_LASTS_FOR}"

source ${DOSARRAY_SCRIPT_DIR}/dosarray_setup_http_experiment.sh


# Next step is to gather the data and analyse it.

CUR_DIR=`pwd`

mkdir -p ${DESTINATION_DIR}
cd ${DESTINATION_DIR}

LOG_COUNT=$(ls ${DOSARRAY_LOG_NAME_PREFIX}*.log | wc -l)

if [ "${LOG_COUNT}" -gt "0" ]
then
  echo "There already appear to be logs in ${DESTINATION_DIR}" >&2
  exit 2
fi

${DOSARRAY_SCRIPT_DIR}/dosarray_gather_container_logs.sh

LOG_COUNT=$(ls ${DOSARRAY_LOG_NAME_PREFIX}*.log | wc -l)
echo "LOG_COUNT=${LOG_COUNT} (Does this look alright?)"

command time ${DOSARRAY_SCRIPT_DIR}/generate_availability_chart.py "${DOSARRAY_LOG_NAME_PREFIX}*.log" > ${DESTINATION_DIR}/availability.data

# And finally we graph it.
${DOSARRAY_SCRIPT_DIR}/dosarray_graphing.sh "${DESTINATION_DIR}" "${TITLE}" "${ATTACK_STARTS_AT}" "$((ATTACK_STARTS_AT+ATTACK_LASTS_FOR))"

cd ${CUR_DIR}
