#/bin/sh
# Container setup for DoSarray
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

echo "Deleting ${DOSARRAY_VIRT_INSTANCES} instances"
for IDX in ${DOSARRAY_PHYSICAL_HOST_IDXS}
do
  HOST_NAME="${DOSARRAY_PHYSICAL_HOSTS_PUB[${IDX}]}"
  HOST_IP="${DOSARRAY_PHYSICAL_HOSTS_PRIV[${IDX}]}"
  echo "Deleting containers in $HOST_NAME (${HOST_IP})"

  printf " \
for CURRENT_CONTAINER_IP in \$(seq $MIN_VIP $MAX_VIP) \n\
do \n\
  CONTAINER_SUFFIX=${DOSARRAY_VIRT_NET_SUFFIX[${IDX}]}.\${CURRENT_CONTAINER_IP} \n\
  CONTAINER_NAME=\"c\${CONTAINER_SUFFIX}\" \n\
  echo -n \"\${CONTAINER_NAME} \" \n\
  docker container rm \${CONTAINER_NAME} & \n\
done \n\
echo " | dosarray_execute_on "${HOST_NAME}" "" \
  > /dev/null

done

echo "Done"
