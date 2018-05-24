#/bin/sh -e
# Filter network load measurements to retain logs only for specific interfaces before generating graphing data
# Shilpi Bose, May 2018, UPenn

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

if [ -z "${DESTINATION_DIR}" ]
then
  echo "\$DESTINATION_DIR needs to be defined" >&2
  exit 2
fi

for (( x=0 ; x < ${#DOSARRAY_PHYSICAL_HOSTS_PUB[@]}; x++ ))
do
  HOSTNAME=${DOSARRAY_PHYSICAL_HOSTS_PUB[$x]}
  INTERFACE=${DOSARRAY_HOST_INTERFACE_MAP[$x]}
  grep "${INTERFACE}" ${DESTINATION_DIR}/${HOSTNAME}_net.log > ${DESTINATION_DIR}/${HOSTNAME}_filtered_net.log
done

echo 'Done'
