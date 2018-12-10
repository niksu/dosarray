#/bin/sh -e
# Experiment setup for DoSarray.
# Nik Sultana, January 2018, UPenn
#
# Use of this source code is governed by the Apache 2.0 license; see LICENSE
#
# Configure a host in the physical network with the network
# info of the virtual network.
#
# Usage:
# ./dosarray_configure_networking.sh demo02
# ./dosarray_configure_networking.sh demo03

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

while getopts ":r" opt; do
  case ${opt} in
    r )
      ADD_ROUTES=true
      ;;
    ? )
      echo "Usage: ./dosarray_configure_network [-r] <target-physical-host>"
      exit 1
      ;;
  esac
done
shift $((OPTIND -1))

TARGET_PHYSICAL_HOST=$1

for IDX in ${DOSARRAY_PHYSICAL_HOST_IDXS}
do
  if [ "${TARGET_PHYSICAL_HOST}" == "${DOSARRAY_PHYSICAL_HOSTS_PUB[$IDX]}" ]
  then
    TARGET_IDX=${IDX}
    break
  fi
done

if [ -z "${TARGET_IDX}" ]
then
  echo "Could not find host ${TARGET_PHYSICAL_HOST} in DOSARRAY_PHYSICAL_HOSTS_PUB=${DOSARRAY_PHYSICAL_HOSTS_PUB[@]}" >&2
  exit 1
fi

DOSARRAY_VIRTUAL_NETWORK="${DOSARRAY_VIRT_NETS[${TARGET_IDX}]}0"

echo "Targetting TARGET_PHYSICAL_HOST=${TARGET_PHYSICAL_HOST} TARGET_IDX=${TARGET_IDX} DOSARRAY_VIRTUAL_NETWORK=${DOSARRAY_VIRTUAL_NETWORK}"

CMD="sudo iptables -t nat -D POSTROUTING -s ${DOSARRAY_VIRTUAL_NETWORK}/24 ! -o docker_bridge -j MASQUERADE \
&& sudo iptables -D FORWARD -o docker_bridge -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT \
&& sudo iptables -A FORWARD -o docker_bridge -j ACCEPT"

for IDX in `seq 0 $(( ${#DOSARRAY_PHYSICAL_HOSTS_PUB[@]} - 1 ))`
do
  if [ "${IDX}" -ne "${TARGET_IDX}" ]
  then
    HOST_IP=${DOSARRAY_PHYSICAL_HOSTS_PRIV[$IDX]}
    VIRTUAL_NETWORK="${DOSARRAY_VIRT_NETS[${IDX}]}0"
    if [ ${ADD_ROUTES} ]
    then
      CMD="${CMD} ; sudo route add -net ${VIRTUAL_NETWORK} netmask 255.255.255.0 gw ${HOST_IP}"
    else
      CMD="${CMD}"
    fi
  fi
done

echo "Running CMD=${CMD}"
echo
echo "Please enter sudo password for ${TARGET_PHYSICAL_HOST} when prompted"

dosarray_execute_on "${TARGET_PHYSICAL_HOST}" "${CMD}"
