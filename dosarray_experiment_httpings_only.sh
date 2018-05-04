#/bin/sh -e
# Experiment setup for DoSarray.
# Nik Sultana, December 2017, UPenn
#
# Use of this source code is governed by the Apache 2.0 license; see LICENSE

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

# NOTE CURRENT_HOST_IP==2 since we skip the first physical machine (because we run the target on it).
CURRENT_HOST_IP=${DOSARRAY_VIRT_NET_SUFFIX[0]}

# NOTE excluding the first host since we're running the server there.
for IDX in `dosarray_physical_hosts_skip 1`
do
  CURRENT_HOST_IP=$((CURRENT_HOST_IP + 1))
  HOST_NAME="${DOSARRAY_PHYSICAL_HOSTS_PUB[${IDX}]}"
  echo "Starting httpings in $HOST_NAME"

  printf "\
${ATTACKERS} \n\
for CURRENT_CONTAINER_IP in \$(seq $DOSARRAY_MIN_VIP $DOSARRAY_MAX_VIP) \n\
do \n\
  CONTAINER_SUFFIX=${CURRENT_HOST_IP}.\${CURRENT_CONTAINER_IP} \n\
  CONTAINER_NAME=\"c\${CONTAINER_SUFFIX}\" \n\
  if ! is_attacker \"\$CONTAINER_NAME\" \n\
  then \n\
    docker container exec \${CONTAINER_NAME} \
      ${MEASUREMENT_COMMAND} \
      > \${CONTAINER_NAME}.log & \n\
  fi \n\
done \n\
echo \n\
" | dosarray_execute_on "${HOST_NAME}" "" &
done

DOUBLE_EXPERIMENT_DURATION=$(echo "2 * ${EXPERIMENT_DURATION}" | bc -l)
sleep ${DOUBLE_EXPERIMENT_DURATION}

echo "Done"
