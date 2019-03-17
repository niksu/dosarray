#/bin/sh -e
# Log gathering in DoSarray
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

for IDX in ${DOSARRAY_CONTAINER_HOST_IDXS}
do
  HOST_NAME="${DOSARRAY_PHYSICAL_HOSTS_PUB[${IDX}]}"
  echo "Gathering container logs from $HOST_NAME"
  echo Running dosarray_scp_from "${HOST_NAME}" "${DOSARRAY_LOG_PATH_PREFIX}/${DOSARRAY_LOG_NAME_PREFIX}*.log" "." >&2
  dosarray_execute_on "${HOST_NAME}" "ls ${DOSARRAY_LOG_PATH_PREFIX}/${DOSARRAY_LOG_NAME_PREFIX}*.log" "" "capture" ""
  # We have to first get a list of files and then copy them one by on,
  # since dosarray_scp_from doesn't work with wildcards since these
  # aren't given meaning if there are intermediate access nodes.
  # We can only map specific files to specific files when copying, not
  # "*" to a path as we can normally do with "cp"..
  for FILE in ${REMOTE_RESULT}
  do
    dosarray_scp_from "${HOST_NAME}" "${FILE}" ${DOSARRAY_DESTINATION_DIR}/$(basename ${FILE})
  done
  echo Running dosarray_execute_on "${HOST_NAME}" "rm ${DOSARRAY_LOG_PATH_PREFIX}/${DOSARRAY_LOG_NAME_PREFIX}*.log" >&2
  dosarray_execute_on "${HOST_NAME}" "rm ${DOSARRAY_LOG_PATH_PREFIX}/${DOSARRAY_LOG_NAME_PREFIX}*.log"
done

echo "Done"
