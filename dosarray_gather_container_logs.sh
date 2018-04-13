#/bin/sh -e
# Log gathering in DoSarray
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

for IDX in ${DOSARRAY_PHYSICAL_HOST_IDXS}
do
  HOST_NAME="${DOSARRAY_PHYSICAL_HOSTS_PUB[${IDX}]}"
  echo "Gathering container logs from $HOST_NAME"
  echo Running dosarray_scp_from "${HOST_NAME}" "${DOSARRAY_LOG_PATH_PREFIX}/${DOSARRAY_LOG_NAME_PREFIX}*.log" "." >&2
  dosarray_scp_from "${HOST_NAME}" "${DOSARRAY_LOG_PATH_PREFIX}/${DOSARRAY_LOG_NAME_PREFIX}*.log" "."
  echo Running dosarray_execute_on "${HOST_NAME}" "rm ${DOSARRAY_LOG_PATH_PREFIX}/${DOSARRAY_LOG_NAME_PREFIX}*.log" >&2
  dosarray_execute_on "${HOST_NAME}" "rm ${DOSARRAY_LOG_PATH_PREFIX}/${DOSARRAY_LOG_NAME_PREFIX}*.log"
done

echo "Done"
