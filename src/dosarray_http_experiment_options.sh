#/bin/sh -e
# DoSarray setup for HTTP
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

SERVER_IP="${DOSARRAY_PHYSICAL_HOSTS_PRIV[0]}"

PORT_Apache_Worker=8011
PORT_Apache_Event=8013
PORT_Nginx=8012
PORT_lighttpd=8014
PORT_Varnish=8015
PORT_HAproxy=8016
#SERVER_PORT="${PORT_Apache_Worker}"
#SERVER_PORT="${PORT_Nginx}"

ATTACK_Slowloris=1
ATTACK_GoldenEye=2
ATTACK_TorsHammer=3
#ATTACK="${ATTACK_Slowloris}"
