#/bin/sh -e
# Configuration for DoSarray
# Nik Sultana, February 2018, UPenn
#
# Use of this source code is governed by the Apache 2.0 license; see LICENSE

export DOSARRAY_VERSION="0.4"
export DOSARRAY_IMAGE="dosarray_image_v0.2a"

# NOTE we only include cluster machines that participate in the experiment in
#      one form or another. We exclude machines that are not to be touched
#      by DoSarray. We do include machines running "targets" however -- DoSarray
#      won't start containers on these machines, but it will poll their load.
export DOSARRAY_PHYSICAL_HOSTS_PRIV=( 192.168.0.2 192.168.0.3 192.168.0.4 192.168.0.5 192.168.0.6 192.168.0.7 192.168.0.8 192.168.0.9 )
export DOSARRAY_VIRT_NET_SUFFIX=( 2 3 4 5 6 7 8 9 )
# NOTE names in DOSARRAY_PHYSICAL_HOSTS_PUB are "public" only as far as the
#      access node is concerned. If there's no access node then they're
#      expected to be public (i.e., directly accessible from the monitor),
#      otherwise we need to hop through the access node. There may a sequence
#      of access nodes we need to use, in general.
export DOSARRAY_PHYSICAL_HOSTS_PUB=( dedos01 dedos02 dedos03 dedos04 dedos05 dedos06 dedos07 dedos08 )
export DOSARRAY_HOST_INTERFACE_MAP=( em1 em1 em1 em1 em1 em1 em1 em1 )
export DOSARRAY_VIRT_NET_PREFIX="192.168."
export DOSARRAY_VIRT_NETS=( "${DOSARRAY_VIRT_NET_PREFIX}${DOSARRAY_VIRT_NET_SUFFIX[0]}." "${DOSARRAY_VIRT_NET_PREFIX}${DOSARRAY_VIRT_NET_SUFFIX[1]}." "${DOSARRAY_VIRT_NET_PREFIX}${DOSARRAY_VIRT_NET_SUFFIX[2]}." "${DOSARRAY_VIRT_NET_PREFIX}${DOSARRAY_VIRT_NET_SUFFIX[3]}." "${DOSARRAY_VIRT_NET_PREFIX}${DOSARRAY_VIRT_NET_SUFFIX[4]}." "${DOSARRAY_VIRT_NET_PREFIX}${DOSARRAY_VIRT_NET_SUFFIX[5]}." "${DOSARRAY_VIRT_NET_PREFIX}${DOSARRAY_VIRT_NET_SUFFIX[6]}." "${DOSARRAY_VIRT_NET_PREFIX}${DOSARRAY_VIRT_NET_SUFFIX[7]}." )
export DOSARRAY_TARGET_SERVER_INDEX=0
export DOSARRAY_HOST_COLORS=( '#555555' '#777777' '#999999' '#BBBBBB' '#DDDDDD' '#FFFFFF' '#EEEEEE' '#AAAAAA' )

# Check that DOSARRAY_PHYSICAL_HOSTS_PRIV, DOSARRAY_VIRT_NET_SUFFIX, etc all have the same number of elements.
if [ ${#DOSARRAY_PHYSICAL_HOSTS_PRIV[@]} -ne ${#DOSARRAY_VIRT_NET_SUFFIX[@]} ]
then
  printf "Check dosarray_config.sh for errors \nDOSARRAY_PHYSICAL_HOSTS_PRIV=${#DOSARRAY_PHYSICAL_HOSTS_PRIV[@]} elements \nDOSARRAY_VIRT_NET_SUFFIX=${#DOSARRAY_VIRT_NET_SUFFIX[@]} elements\n" >&2
  exit 1
elif [ ${#DOSARRAY_VIRT_NET_SUFFIX[@]} -ne ${#DOSARRAY_PHYSICAL_HOSTS_PUB[@]} ]
then
  printf "Check dosarray_config.sh for errors \nDOSARRAY_VIRT_NET_SUFFIX=${#DOSARRAY_VIRT_NET_SUFFIX[@]} elements \nDOSARRAY_PHYSICAL_HOSTS_PUB=${#DOSARRAY_PHYSICAL_HOSTS_PUB[@]} elements\n" >&2
  exit 1
elif [ ${#DOSARRAY_PHYSICAL_HOSTS_PUB[@]} -ne ${#DOSARRAY_HOST_INTERFACE_MAP[@]} ]
then
  printf "Check dosarray_config.sh for errors \nDOSARRAY_PHYSICAL_HOSTS_PUB=${#DOSARRAY_PHYSICAL_HOSTS_PUB[@]} elements \nDOSARRAY_HOST_INTERFACE_MAP=${#DOSARRAY_HOST_INTERFACE_MAP[@]} elements\n" >&2
  exit 1
elif [ ${#DOSARRAY_HOST_INTERFACE_MAP[@]} -ne ${#DOSARRAY_VIRT_NETS[@]} ]
then
  printf "Check dosarray_config.sh for errors \nDOSARRAY_HOST_INTERFACE_MAP=${#DOSARRAY_HOST_INTERFACE_MAP[@]} elements \nDOSARRAY_VIRT_NETS=${#DOSARRAY_VIRT_NETS[@]} elements\n" >&2
  exit 1
elif [ ${#DOSARRAY_VIRT_NETS[@]} -ne ${#DOSARRAY_HOST_COLORS[@]} ]
then
  printf "Check dosarray_config.sh for errors \nDOSARRAY_VIRT_NETS=${#DOSARRAY_VIRT_NETS[@]} elements \nDOSARRAY_HOST_COLORS=${#DOSARRAY_HOST_COLORS[@]} elements\n" >&2
  exit 1
fi

# Check if target index is within allowed range
if [ ${DOSARRAY_TARGET_SERVER_INDEX} -ge  $(( ${#DOSARRAY_PHYSICAL_HOSTS_PUB[@]} - 1 )) ]
then
  printf "Check dosarray_config.sh for errors \nDOSARRAY_TARGET_SERVER_INDEX cannot exceed $(( ${#DOSARRAY_PHYSICAL_HOSTS_PUB[@]} - 1 ))" >&2
  exit 1
fi

function dosarray_physical_hosts_skip () {
  if [ ${DOSARRAY_TARGET_SERVER_INDEX} -eq 0 ]
  then
    echo `seq $(( ${DOSARRAY_TARGET_SERVER_INDEX} + 1)) $(( ${#DOSARRAY_PHYSICAL_HOSTS_PUB[@]} - 1 ))`
  elif [ ${DOSARRAY_TARGET_SERVER_INDEX} -eq $(( ${#DOSARRAY_PHYSICAL_HOSTS_PUB[@]} - 1 )) ]
  then
    echo `seq 0 $(( ${DOSARRAY_TARGET_SERVER_INDEX} - 1))`
  else
    index=(`seq 0 $(( ${DOSARRAY_TARGET_SERVER_INDEX} - 1))` `seq $(( ${DOSARRAY_TARGET_SERVER_INDEX} + 1)) $(( ${#DOSARRAY_PHYSICAL_HOSTS_PUB[@]} - 1 ))`)
    echo ${index[@]}
  fi
}
export -f dosarray_physical_hosts_skip
export DOSARRAY_PHYSICAL_HOST_IDXS=("`seq 0 $(( ${#DOSARRAY_PHYSICAL_HOSTS_PUB[@]} - 1))`")
export DOSARRAY_CONTAINER_HOST_IDXS=`dosarray_physical_hosts_skip`

export DOSARRAY_VIRT_INSTANCES=10
export DOSARRAY_MIN_VIP=2
export DOSARRAY_MAX_VIP=$((DOSARRAY_VIRT_INSTANCES + (DOSARRAY_MIN_VIP - 1)))

# -t is required to execute network configuration commands with sudo
function dosarray_execute_on () {
  local HOST_NAME="$1"
  local CMD="$2"
  ssh <USERNAME>@${HOST_NAME}.<FULLY_QUALIFIED_NAME> -p <SSH_PORT> -t ${CMD}
}
export -f dosarray_execute_on

function dosarray_scp_from () {
  local HOST_NAME="$1"
  local FROM="$2"
  local TO="$3"
  scp -r -P <SSH_PORT> <USERNAME>@${HOST_NAME}.<FULLY_QUALIFIED_NAME>:${FROM} ${TO}
}
export -f dosarray_scp_from

export DOSARRAY_CONTAINER_PREFIX="c"
export DOSARRAY_LOG_NAME_PREFIX="${DOSARRAY_CONTAINER_PREFIX}"
export DOSARRAY_LOG_PATH_PREFIX="/home/<USERNAME>"

# Set for dosrray_run_http_experiment.sh

# FIXME prefix with DOSARRAY_
#       DESTINATION_DIR
#       ATTACK_STARTS_AT
#       ATTACK_LASTS_FOR
#       EXPERIMENT_DURATION
