#/bin/sh -e
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

echo "Creating ${DOSARRAY_VIRT_INSTANCES} instances"
for IDX in ${DOSARRAY_CONTAINER_HOST_IDXS}
do
  HOST_NAME="${DOSARRAY_PHYSICAL_HOSTS_PUB[${IDX}]}"
  echo "Creating containers in $HOST_NAME"

  printf " \
for CURRENT_CONTAINER_IP in \$(seq $DOSARRAY_MIN_VIP $DOSARRAY_MAX_VIP) \n\
do \n\
  CONTAINER_SUFFIX=${DOSARRAY_VIRT_NET_SUFFIX[${IDX}]}.\${CURRENT_CONTAINER_IP} \n\
  CONTAINER_ADDRESS=${DOSARRAY_VIRT_NET_PREFIX}\${CONTAINER_SUFFIX} \n\
  CONTAINER_NAME=\"${DOSARRAY_CONTAINER_PREFIX}\${CONTAINER_SUFFIX}\" \n\
  echo -n \"\${CONTAINER_NAME} \" \n\
  docker container create -ti --name \${CONTAINER_NAME} --net=docker_bridge --ip=\${CONTAINER_ADDRESS} ${DOSARRAY_IMAGE} & \n\
done \n\
echo " | dosarray_execute_on "${HOST_NAME}" "" "" \
  > /dev/null

done

echo "Done"
