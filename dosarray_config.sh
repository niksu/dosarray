#/bin/sh -e
# Configuration for DoSarray
# Nik Sultana, February 2018, UPenn
#
# Add reference to Apache 2.0 license      
#
# FIXME replace "dedos_" and "Winnow" with DoSarray
# FIXME add another array for VIPs, to avoid using the implicit MIN_VIP-MAX_VIP range.

export DOSARRAY_PHYSICAL_HOSTS_PRIV=( 192.168.1.3 192.168.1.4 192.168.1.5 192.168.1.6 192.168.1.7 192.168.1.8 192.168.1.9 192.168.1.10 )
export DOSARRAY_VIRT_NET_SUFFIX=( 3 4 5 6 7 8 9 10 )
export DOSARRAY_PHYSICAL_HOSTS_PUB=( demo01 demo02 demo03 demo04 demo05 demo06 demo07 demo08 )
export DOSARRAY_VIRT_NET_PREFIX="192.168."
export DOSARRAY_VIRT_NETS=( "${DOSARRAY_VIRT_NET_PREFIX}${DOSARRAY_VIRT_NET_SUFFIX[0]}." "${DOSARRAY_VIRT_NET_PREFIX}${DOSARRAY_VIRT_NET_SUFFIX[1]}." "${DOSARRAY_VIRT_NET_PREFIX}${DOSARRAY_VIRT_NET_SUFFIX[2]}." "${DOSARRAY_VIRT_NET_PREFIX}${DOSARRAY_VIRT_NET_SUFFIX[3]}." "${DOSARRAY_VIRT_NET_PREFIX}${DOSARRAY_VIRT_NET_SUFFIX[4]}." "${DOSARRAY_VIRT_NET_PREFIX}${DOSARRAY_VIRT_NET_SUFFIX[5]}." "${DOSARRAY_VIRT_NET_PREFIX}${DOSARRAY_VIRT_NET_SUFFIX[6]}." "${DOSARRAY_VIRT_NET_PREFIX}${DOSARRAY_VIRT_NET_SUFFIX[7]}." )
#export DOSARRAY_VIRT_NETS=( "${DOSARRAY_VIRT_NET_PREFIX}3." "${DOSARRAY_VIRT_NET_PREFIX}4." "${DOSARRAY_VIRT_NET_PREFIX}5." "${DOSARRAY_VIRT_NET_PREFIX}6." "${DOSARRAY_VIRT_NET_PREFIX}7." "${DOSARRAY_VIRT_NET_PREFIX}8." "${DOSARRAY_VIRT_NET_PREFIX}9." "${DOSARRAY_VIRT_NET_PREFIX}10." )

function dosarray_physical_hosts_skip () {
  local SKIP="$1"
  echo `seq ${SKIP} $(( ${#DOSARRAY_PHYSICAL_HOSTS_PUB[@]} - 1 ))`
}
export -f dosarray_physical_hosts_skip
export DOSARRAY_PHYSICAL_HOST_IDXS=`dosarray_physical_hosts_skip 0`

export DOSARRAY_VIRT_INSTANCES=10
export DOSARRAY_SCRIPT_DIR="/home/nik/dosarray"

function dosarray_execute_on () {
  local HOST_NAME="$1"
  local CMD="$2"
  ssh nik@${HOST_NAME} ${CMD}
}
export -f dosarray_execute_on

function dosarray_scp_from () {
  local HOST_NAME="$1"
  local FROM="$2"
  local TO="$3"
  scp -r nik@${HOST_NAME}:${FROM} ${TO}

}
export -f dosarray_scp_from

# FIXME update other scripts to use these:
export DOSARRAY_CONTAINER_PREFIX="c"
export DOSARRAY_LOG_NAME_PREFIX="${DOSARRAY_CONTAINER_PREFIX}"
export DOSARRAY_LOG_PATH_PREFIX="/home/nik/"

# Set for dosrray_run_http_experiment.sh

# FIXME prefix with DOSARRAY_
#       DESTINATION_DIR
#       ATTACK_STARTS_AT
#       ATTACK_LASTS_FOR
#       EXPERIMENT_DURATION
