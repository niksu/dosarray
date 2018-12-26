#/bin/sh -e
# Carry out HTTP experiment in DoSarray
# Nik Sultana, December 2017, UPenn
#
# Use of this source code is governed by the Apache 2.0 license; see LICENSE

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

${DOSARRAY_SCRIPT_DIR}/src/dosarray_servers_load.sh &

# NOTE skipping the host denoted by DOSARRAY_TARGET_SERVER_INDEX since we're running the server there.
for IDX in ${DOSARRAY_CONTAINER_HOST_IDXS}
do
  CURRENT_HOST_IP=${DOSARRAY_VIRT_NET_SUFFIX[${IDX}]}
  HOST_NAME="${DOSARRAY_PHYSICAL_HOSTS_PUB[${IDX}]}"
  HOST_IP="${DOSARRAY_VIRT_NET_PREFIX}0.${CURRENT_HOST_IP}"
  echo "Starting httpings in $HOST_NAME (${HOST_IP})"

  printf "\
${DOSARRAY_ATTACKERS} \n\
for CURRENT_CONTAINER_IP in \$(seq $DOSARRAY_MIN_VIP $DOSARRAY_MAX_VIP) \n\
do \n\
  CONTAINER_SUFFIX=${CURRENT_HOST_IP}.\${CURRENT_CONTAINER_IP} \n\
  CONTAINER_ADDRESS=${DOSARRAY_VIRT_NET_PREFIX}\${CONTAINER_SUFFIX} \n\
  CONTAINER_NAME=\"${DOSARRAY_CONTAINER_PREFIX}\${CONTAINER_SUFFIX}\" \n\
  if ! is_attacker \"\$CONTAINER_NAME\" \n\
  then \n\
    docker container exec \${CONTAINER_NAME} \
      ${MEASUREMENT_COMMAND} \
      > \${CONTAINER_NAME}.log & \n\
  else \n\
    docker container exec \${CONTAINER_NAME} bash -c \"sleep ${DOSARRAY_ATTACK_STARTS_AT} ; ${ATTACK_COMMAND}\" & \n\
    echo -n \"!\${CONTAINER_NAME} \" \n\
  fi \n\
done \n\
echo \n\
echo \"Sleeping until attack ends ${ATTACK_END_TIME}...\" \n\
sleep ${ATTACK_END_TIME} \n\
for CURRENT_CONTAINER_IP in \$(seq $DOSARRAY_MIN_VIP $DOSARRAY_MAX_VIP) \n\
do \n\
  CONTAINER_SUFFIX=${CURRENT_HOST_IP}.\${CURRENT_CONTAINER_IP} \n\
  CONTAINER_ADDRESS=${DOSARRAY_VIRT_NET_PREFIX}\${CONTAINER_SUFFIX} \n\
  CONTAINER_NAME=\"${DOSARRAY_CONTAINER_PREFIX}\${CONTAINER_SUFFIX}\" \n\
  if is_attacker \"\$CONTAINER_NAME\" \n\
  then \n\
    docker container exec \${CONTAINER_NAME} \
      ${STOP_ATTACK_COMMAND} & \n\
    echo -n \"!\${CONTAINER_NAME} \" \n\
  fi \n\
done \n\
echo \"Sleeping until experiment ends ${POST_ATTACK_PERIOD}...\" \n\
sleep ${POST_ATTACK_PERIOD} \n\
for CURRENT_CONTAINER_IP in \$(seq $DOSARRAY_MIN_VIP $DOSARRAY_MAX_VIP) \n\
do \n\
  CONTAINER_SUFFIX=${CURRENT_HOST_IP}.\${CURRENT_CONTAINER_IP} \n\
  CONTAINER_ADDRESS=${DOSARRAY_VIRT_NET_PREFIX}\${CONTAINER_SUFFIX} \n\
  CONTAINER_NAME=\"${DOSARRAY_CONTAINER_PREFIX}\${CONTAINER_SUFFIX}\" \n\
  if ! is_attacker \"\$CONTAINER_NAME\" \n\
  then \n\
    docker container exec \${CONTAINER_NAME} \
      ${STOP_MEASUREMENT_COMMAND} & \n\
    echo -n \"\${CONTAINER_NAME} \" \n\
  fi \n\
done \n\
echo \n\
" | dosarray_execute_on "${HOST_NAME}" "" &
done

DOUBLE_EXPERIMENT_DURATION=$(echo "2 * ${DOSARRAY_EXPERIMENT_DURATION}" | bc -l)
sleep ${DOUBLE_EXPERIMENT_DURATION}

echo "Done"
