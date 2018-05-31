#/bin/sh -e
# Configuration for DoSarray
# Nik Sultana, February 2018, UPenn
#
# Use of this source code is governed by the Apache 2.0 license; see LICENSE

export DOSARRAY_VERSION="0.2"

export DOSARRAY_PHYSICAL_HOSTS_PRIV=( 192.168.0.2 192.168.0.3 192.168.0.4 192.168.0.5 192.168.0.6 192.168.0.7 192.168.0.8 192.168.0.9 )
export DOSARRAY_VIRT_NET_SUFFIX=( 2 3 4 5 6 7 8 9 )
export DOSARRAY_PHYSICAL_HOSTS_PUB=( dedos01 dedos02 dedos03 dedos04 dedos05 dedos06 dedos07 dedos08 )
export DOSARRAY_HOST_INTERFACE_MAP=( em1 em1 em1 em1 em1 em1 em1 em1 )
export DOSARRAY_VIRT_NET_PREFIX="192.168."
export DOSARRAY_VIRT_NETS=( "${DOSARRAY_VIRT_NET_PREFIX}${DOSARRAY_VIRT_NET_SUFFIX[0]}." "${DOSARRAY_VIRT_NET_PREFIX}${DOSARRAY_VIRT_NET_SUFFIX[1]}." "${DOSARRAY_VIRT_NET_PREFIX}${DOSARRAY_VIRT_NET_SUFFIX[2]}." "${DOSARRAY_VIRT_NET_PREFIX}${DOSARRAY_VIRT_NET_SUFFIX[3]}." "${DOSARRAY_VIRT_NET_PREFIX}${DOSARRAY_VIRT_NET_SUFFIX[4]}." "${DOSARRAY_VIRT_NET_PREFIX}${DOSARRAY_VIRT_NET_SUFFIX[5]}." "${DOSARRAY_VIRT_NET_PREFIX}${DOSARRAY_VIRT_NET_SUFFIX[6]}." "${DOSARRAY_VIRT_NET_PREFIX}${DOSARRAY_VIRT_NET_SUFFIX[7]}." )

function dosarray_physical_hosts_skip () {
  local SKIP="$1"
  echo `seq ${SKIP} $(( ${#DOSARRAY_PHYSICAL_HOSTS_PUB[@]} - 1 ))`
}
export -f dosarray_physical_hosts_skip
export DOSARRAY_PHYSICAL_HOST_IDXS=`dosarray_physical_hosts_skip 0`
export DOSARRAY_CONTAINER_HOST_IDXS=`dosarray_physical_hosts_skip 1`

export DOSARRAY_VIRT_INSTANCES=10
export DOSARRAY_MIN_VIP=2
export DOSARRAY_MAX_VIP=$((DOSARRAY_VIRT_INSTANCES + (DOSARRAY_MIN_VIP - 1)))
function dosarray_execute_on () {
  local HOST_NAME="$1"
  local CMD="$2"
  ssh shilpi@${HOST_NAME}.<FULLY_QUALIFIED_NAME> -p <SSH_PORT> ${CMD}
}
export -f dosarray_execute_on

function dosarray_scp_from () {
  local HOST_NAME="$1"
  local FROM="$2"
  local TO="$3"
  scp -r -P <SSH_PORT> shilpi@${HOST_NAME}.<FULLY_QUALIFIED_NAME>:${FROM} ${TO}

}
export -f dosarray_scp_from

# FIXME update other scripts to use these:
export DOSARRAY_CONTAINER_PREFIX="c"
export DOSARRAY_LOG_NAME_PREFIX="${DOSARRAY_CONTAINER_PREFIX}"
export DOSARRAY_LOG_PATH_PREFIX="/home/shilpi"

# Set for dosrray_run_http_experiment.sh

# FIXME prefix with DOSARRAY_
#       DESTINATION_DIR
#       ATTACK_STARTS_AT
#       ATTACK_LASTS_FOR
#       EXPERIMENT_DURATION
