#/bin/sh -e
# Check DoSarray setup
# Nik Sultana, March 2019, UPenn
#
# Use of this source code is governed by the Apache 2.0 license; see LICENSE
#
# FIXME we only support IPv4
# FIXME various hard-codes, such as "docker_bridge"

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

DOCKER_BRIDGE=docker_bridge

tput sgr0
tput rmso
tput rmul


for IDX in ${DOSARRAY_PHYSICAL_HOST_IDXS}
do
  HOST_NAME="${DOSARRAY_PHYSICAL_HOSTS_PUB[${IDX}]}"
  HOST_IP="${DOSARRAY_PHYSICAL_HOSTS_PRIV[${IDX}]}"
  tput setaf 4
  echo -n "Checking "
  tput smso
  echo -n "$HOST_NAME"
  tput rmso
  echo -n " (${HOST_IP})"
  tput sgr0
  echo ""


#  echo -n "  Checking host reachable: "
#  dosarray_execute_on "${HOST_NAME}" "uname -a" "-q" 2>&1 > /dev/null
#  RESULT="$?"
#  if [ "$RESULT" == "0" ]
#  then
#    tput smso
#    echo "OK"
#    tput rmso
#  else
#    tput smso
#    echo "FAIL ($RESULT)"
#    tput rmso
#    break
#  fi
#
#  echo -n "  Checking has Docker: "
#  dosarray_execute_on "${HOST_NAME}" "docker --version" "-q" 2>&1 > /dev/null
#  RESULT="$?"
#  if [ "$RESULT" == "0" ]
#  then
#    tput smso
#    echo "OK"
#    tput rmso
#  else
#    tput smso
#    echo "FAIL ($RESULT)"
#    tput rmso
#    break
#  fi
#
#  echo -n "  Checking has DoSarray image: "
#  dosarray_execute_on "${HOST_NAME}" "docker images | grep dosarray" "-q" 2>&1 > /dev/null
#  RESULT="$?"
#  if [ "$RESULT" == "0" ]
#  then
#    tput smso
#    echo "OK"
#    tput rmso
#  else
#    tput smso
#    echo "FAIL ($RESULT)"
#    tput rmso
#    break
#  fi



#  echo -n "  Checking has network interface \"${DOSARRAY_HOST_INTERFACE_MAP[${IDX}]}\": "
#  dosarray_execute_on "${HOST_NAME}" "ifconfig ${DOSARRAY_HOST_INTERFACE_MAP[${IDX}]}" "-q" 2>&1 > /dev/null
#  RESULT="$?"
#  if [ "$RESULT" == "0" ]
#  then
#    tput smso
#    echo "OK"
#    tput rmso
#  else
#    tput smso
#    echo "FAIL ($RESULT)"
#    tput rmso
#    break
#  fi
#
#  echo -n "  Checking that interface \"${DOSARRAY_HOST_INTERFACE_MAP[${IDX}]}\" has IP \"${DOSARRAY_PHYSICAL_HOSTS_PRIV[${IDX}]}\": "
#  dosarray_execute_on "${HOST_NAME}" "ifconfig ${DOSARRAY_HOST_INTERFACE_MAP[${IDX}]} | grep \"inet addr\" | sed 's/^.*inet addr:\([^ ]*\).*$/\1/'" "-q" 2>&1 > /dev/null
#  RESULT="$?"
#  if [ ! "$RESULT" == "0" ]
#  then
#    tput smso
#    echo "PRE-FAIL ($RESULT)"
#    tput rmso
#    break
#  fi
#
#  if [ "${REMOTE_RESULT}" == "${DOSARRAY_PHYSICAL_HOSTS_PRIV[${IDX}]}" ]
#  then
#    tput smso
#    echo "OK"
#    tput rmso
#  else
#    tput smso
#    echo "FAIL (${REMOTE_RESULT})"
#    tput rmso
#    break
#  fi

  echo -n "  Checking has network interface \"${DOCKER_BRIDGE}\": "
  dosarray_execute_on "${HOST_NAME}" "ifconfig ${DOCKER_BRIDGE}" "-q" 2>&1 > /dev/null
  RESULT="$?"
  if [ "$RESULT" == "0" ]
  then
    tput smso
    echo "OK"
    tput rmso
  else
    tput smso
    echo "FAIL ($RESULT)"
    tput rmso
#    break
  fi

  echo -n "  Checking that interface \"${DOCKER_BRIDGE}\" has IP \"${DOSARRAY_VIRT_NETS[${IDX}]}\": "
  dosarray_execute_on "${HOST_NAME}" "ifconfig ${DOCKER_BRIDGE} | grep \"inet addr\" | sed 's/^.*inet addr:\([^ ]*\).*$/\1/'" "-q" "capture" 2>&1 > /dev/null
  RESULT="$?"
  if [ ! "$RESULT" == "0" ]
  then
    tput smso
    echo "PRE-FAIL ($RESULT)"
    tput rmso
#    break
  fi

  if [[ "${REMOTE_RESULT}" =~ "${DOSARRAY_VIRT_NETS[${IDX}]}" ]]
  then
    tput smso
    echo "OK"
    tput rmso
  else
    tput smso
    echo "FAIL (${REMOTE_RESULT})"
    tput rmso
#    break
  fi

  echo  "  Checking if host routing configured for DoSarray: "
  # Make sure that all other hosts' subnets are reachable.
  for SUB_IDX in ${DOSARRAY_PHYSICAL_HOST_IDXS}
  do
    VIRTUAL_NETWORK="${DOSARRAY_VIRT_NETS[${SUB_IDX}]}0"
    echo -n "    ${DOSARRAY_PHYSICAL_HOSTS_PUB[${SUB_IDX}]}: "
    dosarray_execute_on "${HOST_NAME}" "route | grep ${VIRTUAL_NETWORK}" "-q" 2>&1 > /dev/null
    RESULT="$?"
    if [ "$RESULT" == "0" ]
    then
      tput smso
      echo "OK"
      tput rmso
    else
      tput smso
      echo "FAIL ($RESULT)"
      tput rmso
#      break
    fi
  done


#  echo -n "  Checking if host's routing configured for DoSarray: "    
#  dosarray_execute_on "${HOST_NAME}" "" "sudo sh -c 'iptables -S | grep -E \"^-A FORWARD -o docker_bridge -j ACCEPT\"; echo $?'"
#  dosarray_execute_on "${HOST_NAME}" "" "sudo sh -c 'iptables -S | grep -E \"^-A FORWARD -o docker_bridge -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT\" | echo $?'"

  echo ""
done

tput sgr0
echo "Done"
