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

while getopts ":g" opt; do
  case ${opt} in
    g )
      GRAPHING=true
      ;;
    ? )
      echo "Usage: ./dosarray_run_http_experiment [-g] <target-choice> <attack-choice>"
      exit 1
      ;;
  esac
done
shift $((OPTIND -1))

source ${DOSARRAY_SCRIPT_DIR}/src/dosarray_http_experiment_options.sh

SERVER_CHOICE=$1
ATTACK_CHOICE=$2

if [ -z "${DOSARRAY_DESTINATION_DIR}" ]
then
  echo "\$DOSARRAY_DESTINATION_DIR needs to be defined" >&2
  exit 2
fi

if [ -d "${DOSARRAY_DESTINATION_DIR}" ]
then
  echo "\$DOSARRAY_DESTINATION_DIR (${DOSARRAY_DESTINATION_DIR}) already exists" >&2
  exit 2
fi
mkdir -p ${DOSARRAY_DESTINATION_DIR}

if [ -z "${TITLE}" ]
then
  echo "\$TITLE needs to be defined" >&2
  exit 2
fi

if [ -z "${ATTACKERS}" ]
then
  echo "WARNING! This experiment does not involve any attackers." >&2
fi
echo "\$ATTACKERS: ${ATTACKERS}"

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
elif [ "${SERVER_CHOICE}" == "dedos_web" ]
then
  if [ -z "${DOSARRAY_HTTP_SSL}" ]
  then
    echo "This target (${SERVER_CHOICE}) only works over SSL. Set \$DOSARRAY_HTTP_SSL to enable HTTPS attacks.'" >&2
    exit 1
  fi
  SERVER_PORT="${PORT_DeDOS_HTTP}"
else
  echo "Unknown server choice: '${SERVER_CHOICE}'" >&2
  exit 1
fi
echo "SERVER_PORT=${SERVER_PORT}" >&2

# Check that server is running -- prompt user to activate it.
${DOSARRAY_SCRIPT_DIR}/src/dosarray_http_server_test.sh "${SERVER_CHOICE}"
TEST_RESULT="$?"
if [ "${TEST_RESULT}" -ne "200" ]
then
  echo "Server (${SERVER_CHOICE}) doesn't appear to be running" >&2
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
elif [ "${ATTACK_CHOICE}" == "hulk" ]
then
  ATTACK="${ATTACK_HULK}"
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


echo "EXPERIMENT_DURATION=${EXPERIMENT_DURATION}"
echo "DOSARRAY_VIRT_INSTANCES=${DOSARRAY_VIRT_INSTANCES}"
echo "ATTACK_STARTS_AT=${ATTACK_STARTS_AT}"
echo "ATTACK_LASTS_FOR=${ATTACK_LASTS_FOR}"

# check that an attack duration lies between experiment duration
if [ ${ATTACK_STARTS_AT} -gt ${EXPERIMENT_DURATION} ]
then
    printf "Attack must start before experiment ends\nAttack starts at=${ATTACK_STARTS_AT}\nExperiment duration=${EXPERIMENT_DURATION}" >&2
    exit 1
elif [ $(( ${ATTACK_STARTS_AT} + ${ATTACK_LASTS_FOR} )) -gt ${EXPERIMENT_DURATION} ]
then
    printf "Attack lasts longer than experiment duration \nAttack ends at=$(( ${ATTACK_STARTS_AT} + ${ATTACK_LASTS_FOR} ))\nExperiment Duration=${EXPERIMENT_DURATION}" >&2
    exit 1
fi

source ${DOSARRAY_SCRIPT_DIR}/src/dosarray_setup_http_experiment.sh


# Next step is to gather the data and analyse it.

CUR_DIR=`pwd`

cd ${DOSARRAY_DESTINATION_DIR}

LOG_COUNT=$(ls ${DOSARRAY_LOG_NAME_PREFIX}*.log | wc -l)

if [ "${LOG_COUNT}" -gt "0" ]
then
  echo "There already appear to be logs in ${DOSARRAY_DESTINATION_DIR}" >&2
  exit 2
fi

${DOSARRAY_SCRIPT_DIR}/src/dosarray_gather_container_logs.sh

LOG_COUNT=$(ls ${DOSARRAY_LOG_NAME_PREFIX}*.log | wc -l)
echo "LOG_COUNT=${LOG_COUNT} (Does this look alright?)"

if [ ${GRAPHING} ]
then
  echo "Running graphing"
  ${DOSARRAY_SCRIPT_DIR}/src/dosarray_run_experiment_graphing.sh ${DOSARRAY_DESTINATION_DIR}
fi

cd ${CUR_DIR}
