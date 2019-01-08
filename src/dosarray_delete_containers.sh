#/bin/sh
# Container setup for DoSarray
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

mkdir ${DOSARRAY_SCRIPT_DIR}/host_logs
echo "Deleting ${DOSARRAY_VIRT_INSTANCES} instances"
for IDX in ${DOSARRAY_CONTAINER_HOST_IDXS}
do
  HOST_NAME="${DOSARRAY_PHYSICAL_HOSTS_PUB[${IDX}]}"
  HOST_IP="${DOSARRAY_PHYSICAL_HOSTS_PRIV[${IDX}]}"
  echo "Deleting containers in $HOST_NAME (${HOST_IP})"

  printf " \
echo \"\$(date) starting dosarray_delete_containers.sh\" >> /tmp/dosarray.stdout \n\
for CURRENT_CONTAINER_IP in \$(seq $DOSARRAY_MIN_VIP $DOSARRAY_MAX_VIP) \n\
do \n\
  CONTAINER_SUFFIX=${DOSARRAY_VIRT_NET_SUFFIX[${IDX}]}.\${CURRENT_CONTAINER_IP} \n\
  CONTAINER_NAME=\"${DOSARRAY_CONTAINER_PREFIX}\${CONTAINER_SUFFIX}\" \n\
  echo \"  deleting \${CONTAINER_NAME}\" >> /tmp/dosarray.stdout \n\
  docker container rm \${CONTAINER_NAME} >> /tmp/dosarray.stdout 2>> /tmp/dosarray.stderr & \n\
done \n\
echo \"\$(date) finishing dosarray_delete_containers.sh\" >> /tmp/dosarray.stdout \n\
echo " | dosarray_execute_on "${HOST_NAME}" "" \
  > /dev/null

  echo "Gathering stdout and stderr logs from $HOST_NAME"
  dosarray_scp_from "${HOST_NAME}" "/tmp/dosarray.stdout" "${DOSARRAY_SCRIPT_DIR}/host_logs/dosarray_${HOST_NAME}.stdout"
  dosarray_scp_from "${HOST_NAME}" "/tmp/dosarray.stderr" "${DOSARRAY_SCRIPT_DIR}/host_logs/dosarray_${HOST_NAME}.stderr"
  dosarray_execute_on "${HOST_NAME}" "rm /tmp/dosarray.std*"

done

echo "Done"
