#/bin/sh -e
# Check DoSarray setup
# Nik Sultana, March 2019, UPenn
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

tput sgr0
tput rmso
tput rmul


for IDX in ${DOSARRAY_CONTAINER_HOST_IDXS}
do
  HOST_NAME="${DOSARRAY_PHYSICAL_HOSTS_PUB[${IDX}]}"
  HOST_IP="${DOSARRAY_PHYSICAL_HOSTS_PRIV[${IDX}]}"
  echo -n "Checking "
  tput smso
  echo -n "$HOST_NAME"
  tput rmso
  echo " (${HOST_IP})\n"

  dosarray_execute_on "${HOST_NAME}" "" "docker --version"
  dosarray_execute_on "${HOST_NAME}" "" "docker images | grep dosarray"
  dosarray_execute_on "${HOST_NAME}" "" "ifconfig ${DOSARRAY_HOST_INTERFACE_MAP[${IDX}]}"
  dosarray_execute_on "${HOST_NAME}" "" "ifconfig docker_bridge"
  VIRTUAL_NETWORK="${DOSARRAY_VIRT_NETS[${IDX}]}0"
  dosarray_execute_on "${HOST_NAME}" "" "route | grep ${VIRTUAL_NETWORK}"

  dosarray_execute_on "${HOST_NAME}" "" "sudo sh -c 'iptables -S | grep -E \"^-A FORWARD -o docker_bridge -j ACCEPT\"; echo $?'"
  dosarray_execute_on "${HOST_NAME}" "" "sudo sh -c 'iptables -S | grep -E \"^-A FORWARD -o docker_bridge -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT\" | echo $?'"

  echo ""
done

echo "Done"
