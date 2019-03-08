#/bin/sh -e
# Host time-synching for DoSarray
# Nik Sultana, January 2019, UPenn
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

echo "Starting ${DOSARRAY_VIRT_INSTANCES} instances"
for IDX in ${DOSARRAY_CONTAINER_HOST_IDXS}
do
  HOST_NAME="${DOSARRAY_PHYSICAL_HOSTS_PUB[${IDX}]}"
  HOST_IP="${DOSARRAY_PHYSICAL_HOSTS_PRIV[${IDX}]}"
  echo "Synching time in $HOST_NAME (${HOST_IP})"
  dosarray_execute_on "${HOST_NAME}" "ntpdate -s time.nist.gov"
done

echo "Done"
